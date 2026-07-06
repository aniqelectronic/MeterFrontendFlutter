import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Termios constants for Linux
const int TCSANOW = 0;
const int TCGETS = 0x5401;
const int TCSETS = 0x5402;
const int O_RDWR = 0x0002;
const int O_NOCTTY = 0x0100;
const int O_NONBLOCK = 0x0800;

// Baud rate constants
const int B9600 = 0x0000D;
const int B115200 = 0x01002;

// Control flags
const int CSIZE = 0x00030;
const int CS8 = 0x00030;
const int CSTOPB = 0x00040;
const int CREAD = 0x00080;
const int PARENB = 0x00100;
const int PARODD = 0x00200;
const int CLOCAL = 0x00800;

// Input flags
const int IGNPAR = 0x0004;
const int ICRNL = 0x0100;
const int IXON = 0x0400;

// Output flags
const int OPOST = 0x0001;

// Local flags
const int ICANON = 0x0002;
const int ECHO = 0x0008;
const int ECHOE = 0x0010;
const int ISIG = 0x0001;

// Native C functions
typedef OpenNative = ffi.Int32 Function(
  ffi.Pointer<Utf8> pathname,
  ffi.Int32 flags,
);
typedef OpenDart = int Function(
  ffi.Pointer<Utf8> pathname,
  int flags,
);

typedef CloseNative = ffi.Int32 Function(ffi.Int32 fd);
typedef CloseDart = int Function(int fd);

typedef ReadNative = ffi.IntPtr Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Uint8> buf,
  ffi.IntPtr count,
);
typedef ReadDart = int Function(
  int fd,
  ffi.Pointer<ffi.Uint8> buf,
  int count,
);

typedef WriteNative = ffi.IntPtr Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Uint8> buf,
  ffi.IntPtr count,
);
typedef WriteDart = int Function(
  int fd,
  ffi.Pointer<ffi.Uint8> buf,
  int count,
);

typedef IoctlNative = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Uint64 request,
  ffi.Pointer<ffi.Void> argp,
);
typedef IoctlDart = int Function(
  int fd,
  int request,
  ffi.Pointer<ffi.Void> argp,
);

// Termios structure (simplified for ARM64)
base class Termios extends ffi.Struct {
  @ffi.Uint32()
  external int c_iflag;
  
  @ffi.Uint32()
  external int c_oflag;
  
  @ffi.Uint32()
  external int c_cflag;
  
  @ffi.Uint32()
  external int c_lflag;
  
  @ffi.Uint8()
  external int c_line;
  
  @ffi.Array(32)
  external ffi.Array<ffi.Uint8> c_cc;
  
  @ffi.Uint32()
  external int c_ispeed;
  
  @ffi.Uint32()
  external int c_ospeed;
}

class NativeSerialPort {
  late ffi.DynamicLibrary _libc;
  late OpenDart _open;
  late CloseDart _close;
  late ReadDart _read;
  late WriteDart _write;
  late IoctlDart _ioctl;
  
  int? _fd;
  final String portPath;
  
  NativeSerialPort(this.portPath) {
    _libc = ffi.DynamicLibrary.open('libc.so.6');
    
    _open = _libc.lookupFunction<OpenNative, OpenDart>('open');
    _close = _libc.lookupFunction<CloseNative, CloseDart>('close');
    _read = _libc.lookupFunction<ReadNative, ReadDart>('read');
    _write = _libc.lookupFunction<WriteNative, WriteDart>('write');
    _ioctl = _libc.lookupFunction<IoctlNative, IoctlDart>('ioctl');
  }
  
  bool open({
    int baudRate = 9600,
    int dataBits = 8,
    int stopBits = 1,
    int parity = 0,
  }) {
    try {
      print('[NativeSerial] Opening port: $portPath');
      
      // Open the serial port
      final pathPtr = portPath.toNativeUtf8();
      _fd = _open(pathPtr, O_RDWR | O_NOCTTY);
      malloc.free(pathPtr);
      
      if (_fd! < 0) {
        print('[NativeSerial] Failed to open port, fd: $_fd');
        return false;
      }
      
      print('[NativeSerial] Port opened, fd: $_fd');
      
      // Get current termios settings
      final termiosPtr = malloc<Termios>();
      int result = _ioctl(_fd!, TCGETS, termiosPtr.cast());
      
      if (result < 0) {
        print('[NativeSerial] Failed to get termios settings');
        _close(_fd!);
        _fd = null;
        malloc.free(termiosPtr);
        return false;
      }
      
      final termios = termiosPtr.ref;
      
      // Configure termios for raw mode
      termios.c_iflag &= ~(IGNPAR | ICRNL | IXON);
      termios.c_oflag &= ~OPOST;
      termios.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
      
      // Set control flags
      termios.c_cflag &= ~CSIZE;
      termios.c_cflag |= CS8;  // 8 data bits
      termios.c_cflag |= CREAD | CLOCAL;  // Enable receiver, ignore modem control
      
      // Set stop bits
      if (stopBits == 2) {
        termios.c_cflag |= CSTOPB;
      } else {
        termios.c_cflag &= ~CSTOPB;
      }
      
      // Set parity
      if (parity == 0) {
        termios.c_cflag &= ~PARENB;  // No parity
      } else if (parity == 1) {
        termios.c_cflag |= PARENB | PARODD;  // Odd parity
      } else if (parity == 2) {
        termios.c_cflag |= PARENB;  // Even parity
        termios.c_cflag &= ~PARODD;
      }
      
      // Set baud rate
      final speed = baudRate == 115200 ? B115200 : B9600;
      termios.c_ispeed = speed;
      termios.c_ospeed = speed;
      
      // Set minimum characters and timeout
termios.c_cc[5] = 1;  // VTIME = 0.1 seconds (index 5 is VTIME)
termios.c_cc[6] = 0;  // VMIN = 0 (index 6 is VMIN)
      
      // Apply settings
      result = _ioctl(_fd!, TCSETS, termiosPtr.cast());
      malloc.free(termiosPtr);
      
      if (result < 0) {
        print('[NativeSerial] Failed to set termios settings');
        _close(_fd!);
        _fd = null;
        return false;
      }
      
      print('[NativeSerial] Port configured successfully');
      return true;
      
    } catch (e) {
      print('[NativeSerial] Exception during open: $e');
      if (_fd != null && _fd! >= 0) {
        _close(_fd!);
        _fd = null;
      }
      return false;
    }
  }
  
  int write(Uint8List data) {
    if (_fd == null || _fd! < 0) {
      throw StateError('Port not open');
    }
    
    final bufPtr = malloc<ffi.Uint8>(data.length);
    for (int i = 0; i < data.length; i++) {
      bufPtr[i] = data[i];
    }
    
    final written = _write(_fd!, bufPtr, data.length);
    malloc.free(bufPtr);
    
    return written;
  }
  
  Uint8List? read(int maxBytes, {int timeoutMs = 1000}) {
    if (_fd == null || _fd! < 0) {
      throw StateError('Port not open');
    }
    
    final bufPtr = malloc<ffi.Uint8>(maxBytes);
    final bytesRead = _read(_fd!, bufPtr, maxBytes);
    
    if (bytesRead <= 0) {
      malloc.free(bufPtr);
      return null;
    }
    
    final result = Uint8List(bytesRead);
    for (int i = 0; i < bytesRead; i++) {
      result[i] = bufPtr[i];
    }
    
    malloc.free(bufPtr);
    return result;
  }
  
  void close() {
    if (_fd != null && _fd! >= 0) {
      print('[NativeSerial] Closing port fd: $_fd');
      _close(_fd!);
      _fd = null;
    }
  }
  
  bool get isOpen => _fd != null && _fd! >= 0;
}