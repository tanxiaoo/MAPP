import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../const.dart';
import 'package:get/get.dart';

class AttractionCard1 extends StatelessWidget {
  final String title;
  final String description;
  final List<String> imageUrls;
  final String distance;
  const AttractionCard1(
      {super.key,
      required this.title,
      required this.description,
      required this.imageUrls,
      required this.distance,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 6,),
          SizedBox(
            height: 135,
            child: ListView.builder(
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
                        return const Center(child: CircularProgressIndicator()); 
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error, color: Colors.red));
                      },
                    ),
                  ),
                );
            }),
          ),
          const SizedBox(height: 6,),
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
                'lib/images/visit.svg',
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
                        "Visit Here",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.yellow,
                        ),
                      ),
                    ),
              const SizedBox(width: 25),
              SvgPicture.asset(
                'lib/images/plan_favorites.svg',
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
                        "Add List",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.yellow,
                        ),
                      ),
                    ),
              const SizedBox(width: 25),
              SvgPicture.asset(
                'lib/images/plan_lists.svg',
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
                  "Details",
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
