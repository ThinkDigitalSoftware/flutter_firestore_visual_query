class WhereCondition {
  static const String isEqualTo = "isEqualTo";
  static const String isLessThan = "isLessThan";
  static const String isLessThanOrEqualTo = "isLessThanOrEqualTo";
  static const String isGreaterThan = "isGreaterThan";
  static const String isGreaterThanOrEqualTo = "isGreaterThanOrEqualTo";
  static const String arrayContains = "arrayContains";
  static const String isNull = "isNull";

  static const List<String> values = [
    isEqualTo,
    isLessThan,
    isLessThanOrEqualTo,
    isGreaterThan,
    isGreaterThanOrEqualTo,
    arrayContains,
    isNull
  ];
}

class Types {
  static const String string = "string";
  static const String number = "number";
  static const String boolean = "boolean";

  static const List<String> values = [string, number, boolean];
}
