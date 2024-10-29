class Combo {
  final int comboId;
  final String title;
  final String subtitle;
  final String image;
  final int quantity;
  final bool status;
  final bool isCombo;
  final double price;

  Combo({
    required this.comboId,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.quantity,
    required this.status,
    required this.isCombo,
    required this.price,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      comboId: json['ComboID'],
      title: json['Title'],
      subtitle: json['Subtitle'],
      image: json['Image'],
      quantity: json['Quantity'],
      status: json['Status'] == 1,
      isCombo: json['IsCombo'] == 1,
      price: json['Price'].toDouble(),
    );
  }
}
