import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../const.dart';
import 'package:get/get.dart';

class AttractionCard2 extends StatelessWidget {
  final String title;
  final String description;
  final List<String> imageUrls;
  final String distance;
  final VoidCallback? onAddWaypoint;
  const AttractionCard2({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.distance,
    this.onAddWaypoint,
  });

  @override
  Widget build(BuildContext context) {
    const String defaultImageUrl = "https://via.placeholder.com/400x300.png?text=No+Image";
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(
            height: 6,
          ),
          

          SizedBox(
            height: 135,
            child: imageUrls.isNotEmpty 
            ? imageUrls.length == 1
            ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        imageUrls[0],
                        height: 135,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Icon(Icons.error, color: Colors.red));
                        },
                      ),
                    ),
                  )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        imageUrls[index],
                        height: 135,
                        width: 240,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Icon(Icons.error, color: Colors.red));
                        },
                      ),
                    ),
                  );
                }): Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        defaultImageUrl,
                        height: 135,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Icon(Icons.error, color: Colors.red));
                        },
                      ),
                    ),
                  )
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            children: [
              const Icon(
                Icons.place,
                size: 12,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 25),
              SvgPicture.asset(
                'lib/images/start.svg',
                width: 12,
                height: 12,
                colorFilter: const ColorFilter.mode(
                  AppColors.yellow,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  Get.toNamed("/plan");
                },
                child: Text(
                  "Start Here",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              SvgPicture.asset(
                'lib/images/add.svg',
                width: 12,
                height: 12,
                colorFilter: const ColorFilter.mode(
                  AppColors.yellow,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  if (onAddWaypoint != null) {
                    onAddWaypoint!();
                  }
                },
                child: Text(
                  "Add Here",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              SvgPicture.asset(
                'lib/images/end.svg',
                width: 12,
                height: 12,
                colorFilter: const ColorFilter.mode(
                  AppColors.yellow,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  Get.toNamed("/plan");
                },
                child: Text(
                  "End Here",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
