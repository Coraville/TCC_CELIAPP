import 'package:flutter/material.dart';

class AvatarSelectionPage extends StatelessWidget {
  final List<String> avatarPaths = List.generate(
    10,
    (index) => 'assets/avatares/avatar_${index + 1}.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolher Avatar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: avatarPaths.length,
        itemBuilder: (context, index) {
          final avatar = avatarPaths[index];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, avatar); // Retorna o caminho do avatar
            },
            child: CircleAvatar(
              backgroundImage: AssetImage(avatar),
              radius: 40,
            ),
          );
        },
      ),
    );
  }
}
