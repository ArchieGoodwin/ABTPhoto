var argscheck = require('cordova/argscheck'),
  utils = require('cordova/utils'),
  exec = require('cordova/exec');

var PLUGIN_NAME = "CameraPreview";

var CameraPreview = function() {};

CameraPreview.setOnPictureTakenHandler = function(onPictureTaken) {
  exec(onPictureTaken, onPictureTaken, PLUGIN_NAME, "setOnPictureTakenHandler", []);
};

//@param rect {x: 0, y: 0, width: 100, height:100}
//@param defaultCamera "front" | "back"
CameraPreview.startCamera = function(rect, defaultCamera, tapEnabled, dragEnabled, toBack, alpha, storeToGallery, compression, onSuccess, onError) {
  if (typeof(alpha) === 'undefined') alpha = 1;
  if (typeof(storeToGallery) !== 'boolean') storeToGallery = false;
  if (typeof(compression) === 'undefined') compression = 80; // 0-100. 100 => least amount of compression.
    exec(onSuccess, onError, PLUGIN_NAME, "startCamera", [rect.x, rect.y, rect.width, rect.height, defaultCamera, !!tapEnabled, !!dragEnabled, !!toBack, alpha, !!storeToGallery, compression]);
};
CameraPreview.stopCamera = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "stopCamera", []);
};
//@param size {maxWidth: 100, maxHeight:100}
CameraPreview.takePicture = function(size, onSuccess, onError) {
  var params = [0, 0];
  if (size) {
    params = [size.maxWidth, size.maxHeight];
  }
  exec(onSuccess, onError, PLUGIN_NAME, "takePicture", params);
};
CameraPreview.focusCamera = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "focusCamera", []);
};
CameraPreview.setColorEffect = function(effect, onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "setColorEffect", [effect]);
};

CameraPreview.switchCamera = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "switchCamera", []);
};

CameraPreview.hide = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "hideCamera", []);
};

CameraPreview.show = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "showCamera", []);
};

CameraPreview.disable = function(disable, onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "disable", [disable]);
};

CameraPreview.flashOn = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "flashMode", ["on"]);
};
CameraPreview.flashOff = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "flashMode", ["off"]);
};
CameraPreview.flashAuto = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "flashMode", ["auto"]);
};

module.exports = CameraPreview;
