class CurrencyHelper {
  static const double usdToInr = 83.0;
  static const double eurToInr = 90.0;

  static String getSymbol(String code) {
    switch (code) {
      case "USD":
        return "\$";
      case "EUR":
        return "€";
      default:
        return "₹";
    }
  }

  // 🔁 Convert to INR (while saving)
  static double toINR(double amount, String currency) {
    switch (currency) {
      case "USD":
        return amount * usdToInr;
      case "EUR":
        return amount * eurToInr;
      default:
        return amount;
    }
  }

  // 🔁 Convert from INR (while displaying)
  static double fromINR(double amount, String currency) {
    switch (currency) {
      case "USD":
        return amount / usdToInr;
      case "EUR":
        return amount / eurToInr;
      default:
        return amount;
    }
  }
}