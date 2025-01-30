import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../const.dart';

class CustomMarker {
  static Future<BitmapDescriptor> createNumberedMarker({
    required int index, 
    double size = 36,  
    Color borderColor = Colors.white, 
    Color backgroundColor = Colors.blue, 
    double borderWidth = 3, 
    double fontSize = 24, 
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double radius = size / 2;

    final Paint borderPaint = Paint()..color = borderColor;
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    final Paint backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(Offset(radius, radius), radius - borderWidth, backgroundPaint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: index.toString(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, 
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final double textX = radius - (textPainter.width / 2);
    final double textY = radius - (textPainter.height / 2);
    textPainter.paint(canvas, Offset(textX, textY));

    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }


  static Future<BitmapDescriptor> createCustomIconWithImage({
    required String imageUrl,
    double size = 36,
    Color borderColor = Colors.white,
    Color backgroundColor = AppColors.yellow,
    double borderWidth = 3,
  }) async {
    final ByteData imageData = await rootBundle.load(imageUrl);
    final ui.Codec codec = await ui.instantiateImageCodec(
      imageData.buffer.asUint8List(),
      targetWidth: (size * 0.5).toInt(),
    );
    final ui.Image image = (await codec.getNextFrame()).image;
    final double imageXOffset = (size - image.width) / 2;
    final double imageYOffset = (size - image.height) / 2;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double radius = size / 2;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()..color = borderColor,
    );
    canvas.drawCircle(
      Offset(radius, radius),
      radius - borderWidth,
      Paint()..color = backgroundColor,
    );

    canvas.drawImage(image, Offset(imageXOffset, imageYOffset), Paint());

   
    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}

