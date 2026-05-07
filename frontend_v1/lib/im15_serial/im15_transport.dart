/// ------------------------------------------------------------------
/// IM15 Transport Interface
/// ------------------------------------------------------------------
/// Purpose:
/// - Abstract transport layer for serial communication with IM15
/// - Allows controllers/probes to write/read bytes without caring about platform
/// ------------------------------------------------------------------

abstract class IM15Transport {
  /// Ensure the transport is open
  /// Throws exception if unable to open
  Future<void> ensureOpen();

  /// Write raw bytes to transport
  Future<void> write(List<int> data);

  /// Read up to buf.length bytes into buffer
  /// Returns number of bytes read, or -1 if timeout
  Future<int> read(List<int> buf);

  /// True if transport is currently open
  bool get isOpen;

  /// Close transport
  Future<void> close();
}
