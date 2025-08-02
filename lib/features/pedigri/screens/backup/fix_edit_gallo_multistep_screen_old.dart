? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.red, // ✅ TEMA ROJO
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red, // ✅ TEMA ROJO
              ),
            ),
          ],
        ),
      ),
    );
  }
}