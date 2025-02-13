import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart'
    show
        Image,
        Interpolation,
        copyResize,
        decodeImage,
        drawImage,
        encodePng,
        trim;
import 'package:path/path.dart' show basename;
import 'package:cli_util/cli_logging.dart' show Logger;
import 'configuration.dart';
import 'extensions.dart';

/// Handles all the msix and user assets files
class Assets {
  Configuration _config;
  late Image image;
  Logger _logger;
  String get _msixIconsFolderPath => '${_config.buildFilesFolder}/Images';

  Assets(this._config, this._logger);

  /// Generate new app icons or copy default app icons
  Future<void> createIcons() async {
    _logger.trace('create app icons');

    await Directory(_msixIconsFolderPath).create();

    final port = ReceivePort();
    await Isolate.spawn(
        _config.logoPath != null ? _generateAssetsIcons : _copyDefaultsIcons,
        port.sendPort);
    await port.first;
  }

  Future<void> _copyDefaultsIcons(SendPort port) async {
    await Directory(_config.defaultsIconsFolderPath)
        .copyDirectory(Directory(_msixIconsFolderPath));
    Isolate.exit(port);
  }

  /// Copy the VC libs files (msvcp140.dll, vcruntime140.dll, vcruntime140_1.dll)
  Future<void> copyVCLibsFiles() async {
    _logger.trace('copying VC libraries');

    await Directory('${_config.msixAssetsPath}/VCLibs/${_config.architecture}')
        .copyDirectory(Directory(_config.buildFilesFolder));
  }

  /// Clear the build folder from temporary files
  Future<void> cleanTemporaryFiles({clearMsixFiles = false}) async {
    _logger.trace('cleaning temporary files');

    final buildPath = _config.buildFilesFolder;

    await Future.wait([
      ...[
        'AppxManifest.xml',
        'resources.pri',
        'resources.scale-125.pri',
        'resources.scale-150.pri',
        'resources.scale-200.pri',
        'resources.scale-400.pri',
        'msvcp140.dll',
        'vcruntime140_1.dll',
        'vcruntime140.dll'
      ].map((fileName) async =>
          await File('$buildPath/$fileName').deleteIfExists()),
      Directory('$buildPath/Images').deleteIfExists(recursive: true),
      clearMsixFiles
          ? Directory(buildPath)
              .list(recursive: true, followLinks: false)
              .where((f) => basename(f.path).contains('.msix'))
              .forEach((file) async => await file.deleteIfExists())
          : Future.value(),
    ]);

    if (clearMsixFiles) {
      await Future.wait([
        ...[
          'installCertificate.ps1',
          'InstallTestCertificate.exe',
          'test_certificate.pfx'
        ].map((fileName) async =>
            await File('$buildPath/$fileName').deleteIfExists()),
      ]);
    }
  }

  /// Generate icon with specified size, padding and scale
  Future<void> _generateIcon(String name, _Size size,
      {double scale = 1,
      double paddingWidthPercent = 0,
      double paddingHeightPercent = 0}) async {
    double scaledWidth = size.width * scale;
    double scaledHeight = size.height * scale;
    int widthLessPaddingWidth =
        (scaledWidth - (scaledWidth * paddingWidthPercent)).ceil();
    int heightLessPaddingHeight =
        (scaledHeight - (scaledHeight * paddingHeightPercent)).ceil();
    Interpolation interpolation =
        widthLessPaddingWidth < 200 || heightLessPaddingHeight < 200
            ? Interpolation.average
            : Interpolation.cubic;

    if (_config.trimLogo) {
      try {
        image = trim(image);
      } catch (e) {}
    }

    Image resizedImage;
    if (widthLessPaddingWidth > heightLessPaddingHeight) {
      resizedImage = copyResize(
        image,
        height: heightLessPaddingHeight,
        interpolation: interpolation,
      );
    } else {
      resizedImage = copyResize(
        image,
        width: widthLessPaddingWidth,
        interpolation: interpolation,
      );
    }

    Image imageCanvas = Image(scaledWidth.ceil(), scaledHeight.ceil());

    var drawX = imageCanvas.width ~/ 2 - resizedImage.width ~/ 2;
    var drawY = imageCanvas.height ~/ 2 - resizedImage.height ~/ 2;
    drawImage(
      imageCanvas,
      resizedImage,
      dstX: drawX > 0 ? drawX : 0,
      dstY: drawY > 0 ? drawY : 0,
      blend: false,
    );

    String fileName = name;
    if (!name.contains('targetsize')) {
      fileName = '$name.scale-${(scale * 100).toInt()}';
    }

    await File('${_config.buildFilesFolder}/Images/$fileName.png')
        .writeAsBytes(encodePng(imageCanvas));
  }

  /// Generate optimized msix icons from the user logo
  Future<void> _generateAssetsIcons(SendPort port) async {
    _logger.trace('generating icons');

    if (!(await File(_config.logoPath!).exists())) {
      throw 'Logo file not found at ${_config.logoPath}';
    }

    try {
      image = decodeImage(await File(_config.logoPath!).readAsBytes())!;
    } catch (e) {
      throw 'Error reading logo file: ${_config.logoPath!}';
    }

    await Future.wait([
      // SmallTile
      _generateIcon('SmallTile', _Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('SmallTile', _Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 1.25),
      _generateIcon('SmallTile', _Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 1.5),
      _generateIcon('SmallTile', _Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 2),
      _generateIcon('SmallTile', _Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 4),
      // Square150x150Logo (Medium tile)
      _generateIcon('Square150x150Logo', _Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('Square150x150Logo', _Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('Square150x150Logo', _Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('Square150x150Logo', _Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('Square150x150Logo', _Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // Wide310x150Logo (Wide tile)
      _generateIcon('Wide310x150Logo', _Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('Wide310x150Logo', _Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('Wide310x150Logo', _Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('Wide310x150Logo', _Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('Wide310x150Logo', _Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // LargeTile
      _generateIcon('LargeTile', _Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('LargeTile', _Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('LargeTile', _Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('LargeTile', _Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('LargeTile', _Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // Square44x44Logo (App icon)
      _generateIcon('Square44x44Logo', _Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16),
      _generateIcon('Square44x44Logo', _Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 1.25),
      _generateIcon('Square44x44Logo', _Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 1.5),
      _generateIcon('Square44x44Logo', _Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 2),
      _generateIcon('Square44x44Logo', _Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 4),
      // targetsize
      _generateIcon('Square44x44Logo.targetsize-16', _Size(16, 16)),
      _generateIcon('Square44x44Logo.targetsize-24', _Size(24, 24)),
      _generateIcon('Square44x44Logo.targetsize-32', _Size(32, 32)),
      _generateIcon('Square44x44Logo.targetsize-48', _Size(48, 48)),
      _generateIcon('Square44x44Logo.targetsize-256', _Size(256, 256)),
      _generateIcon('Square44x44Logo.targetsize-20', _Size(20, 20)),
      _generateIcon('Square44x44Logo.targetsize-30', _Size(30, 30)),
      _generateIcon('Square44x44Logo.targetsize-36', _Size(36, 36)),
      _generateIcon('Square44x44Logo.targetsize-40', _Size(40, 40)),
      _generateIcon('Square44x44Logo.targetsize-60', _Size(60, 60)),
      _generateIcon('Square44x44Logo.targetsize-64', _Size(64, 64)),
      _generateIcon('Square44x44Logo.targetsize-72', _Size(72, 72)),
      _generateIcon('Square44x44Logo.targetsize-80', _Size(80, 80)),
      _generateIcon('Square44x44Logo.targetsize-96', _Size(96, 96)),
      // unplated targetsize
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-16', _Size(16, 16)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-24', _Size(24, 24)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-32', _Size(32, 32)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-48', _Size(48, 48)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-256', _Size(256, 256)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-20', _Size(20, 20)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-30', _Size(30, 30)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-36', _Size(36, 36)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-40', _Size(40, 40)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-60', _Size(60, 60)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-64', _Size(64, 64)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-72', _Size(72, 72)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-80', _Size(80, 80)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-96', _Size(96, 96)),
      // light unplated targetsize
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-16', _Size(16, 16)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-24', _Size(24, 24)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-32', _Size(32, 32)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-48', _Size(48, 48)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-256',
          _Size(256, 256)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-20', _Size(20, 20)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-30', _Size(30, 30)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-36', _Size(36, 36)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-40', _Size(40, 40)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-60', _Size(60, 60)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-64', _Size(64, 64)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-72', _Size(72, 72)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-80', _Size(80, 80)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-96', _Size(96, 96)),
      // SplashScreen
      _generateIcon('SplashScreen', _Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('SplashScreen', _Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('SplashScreen', _Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('SplashScreen', _Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('SplashScreen', _Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // BadgeLogo
      _generateIcon('BadgeLogo', _Size(24, 24)),
      _generateIcon('BadgeLogo', _Size(24, 24), scale: 1.25),
      _generateIcon('BadgeLogo', _Size(24, 24), scale: 1.5),
      _generateIcon('BadgeLogo', _Size(24, 24), scale: 2),
      _generateIcon('BadgeLogo', _Size(24, 24), scale: 4),
      // StoreLogo
      _generateIcon('StoreLogo', _Size(50, 50)),
      _generateIcon('StoreLogo', _Size(50, 50), scale: 1.25),
      _generateIcon('StoreLogo', _Size(50, 50), scale: 1.5),
      _generateIcon('StoreLogo', _Size(50, 50), scale: 2),
      _generateIcon('StoreLogo', _Size(50, 50), scale: 4),
    ]);

    Isolate.exit(port);
  }
}

class _Size {
  final int width;
  final int height;
  const _Size(this.width, this.height);
}
