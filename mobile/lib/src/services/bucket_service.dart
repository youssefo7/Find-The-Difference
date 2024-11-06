class BucketService {
  // making this request HTTP instead of HTTPS somehow reduces the number
  // of images that fails to load on S3
  final _baseUrl = 'http://polydiff.s3.ca-central-1.amazonaws.com';

  get _numberOfDefaultAvatars => 9;

  List<String> get defaultAvatarUrls {
    return [
      for (int i = 1; i <= _numberOfDefaultAvatars; i++)
        '$_baseUrl/avatars/image$i.png'
    ];
  }

  String getFullUrl(String avatarUrl) {
    if (avatarUrl.startsWith(_baseUrl)) return avatarUrl;
    return '$_baseUrl/$avatarUrl';
  }
}
