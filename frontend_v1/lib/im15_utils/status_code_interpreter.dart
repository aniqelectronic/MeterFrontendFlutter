class StatusCodeInterpreter {
  static String interpret(String statusCode) {
    switch (statusCode) {
      case "00":
        return "APPROVED";
      case "05":
        return "DECLINED - CALL BANK";
      case "12":
        return "INVALID TRANSACTION";
      case "54":
        return "CARD EXPIRED";
      case "91":
        return "ISSUER UNAVAILABLE";
      case "PE":
        return "PIN ERROR";
      case "SE":
        return "TERMINAL FULL - SETTLE NOW";
      default:
        return "UNKNOWN STATUS CODE: $statusCode";
    }
  }
}
