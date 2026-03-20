import 'dart:io';
import 'package:cloudinary_api/cloudinary_api.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/upload_request.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

class CloudinaryService {
  final String cloudName = 'diuhfwxio';
  final String apiKey = '456931118672737';
  final String apiSecret = 'RjD6NoosU3SMvxjTocCjoDA2RTs';

  late Cloudinary cloudinary;

  CloudinaryService() {
    // Initialize Cloudinary URL generation
    cloudinary = Cloudinary.fromStringUrl(
      'cloudinary://$apiKey:$apiSecret@$cloudName',
    );
  }

  /// Uploads an image file to Cloudinary and returns the secure URL
  Future<String?> uploadImage(
    File file, {
    String folder = 'familyos_uploads',
  }) async {
    try {
      // NOTE: Using the cloudinary_api package usually requires the apiSecret.
      // If doing unsigned uploads, you'd perform a direct HTTP POST to:
      // https://api.cloudinary.com/v1_1/$cloudName/image/upload
      // with the 'upload_preset' in the body.

      var response = await cloudinary.uploader().upload(
        file,
        params: UploadParams(folder: folder, resourceType: 'auto'),
      );

      return response?.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  /// Generates a transformed URL (e.g., thumbnail)
  String getThumbnailUrl(String publicId, {int width = 200, int height = 200}) {
    // Example of using cloudinary_url_gen for transformations
    // return cloudinary.image(publicId).resize(Resize.fill().width(width).height(height)).toString();
    return 'https://res.cloudinary.com/$cloudName/image/upload/c_fill,h_$height,w_$width/$publicId';
  }
}
