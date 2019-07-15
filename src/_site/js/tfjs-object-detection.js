function isAndroid() {
	return /Android/i.test(navigator.userAgent);
}

function isiOS() {
	return /iPhone|iPad|iPod/i.test(navigator.userAgent);
}

function isMobile() {
	return isAndroid() || isiOS();
}

const videoWidth  = 360;
const videoHeight = 240;


/* Just used to print the list of detectable things.
 */
function detectableClasses () {
  var str = "";
  for (var key in CLASSES) {
    var item = CLASSES[key];
    str += item["displayName"] + ","
  }
  console.log(str);
}


/*
 * Following previous tfjs demos, let's try and get a camera stream.
 */
async function setupCamera () {
	if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
		throw new Error('Browser API navigator.mediaDevices.getUserMedia not available');
	}

  const video  = document.getElementById('video');
  video.width  = videoWidth;
  video.height = videoHeight;

  const mobile = isMobile();

  const stream = await navigator.mediaDevices.getUserMedia({
    'audio': false,
    'video': {
      facingMode: 'user',
      width: mobile ? undefined : videoWidth,
      height: mobile ? undefined : videoHeight,
    },
  });

  video.srcObject = stream;

  return new Promise((resolve) => {
    video.onloadedmetadata = () => {
      resolve(video);
    };
  });
}


/* Load the camera, load the model, then kick off the detection loop!
 */
async function startDetection () {
  var loading = document.getElementById("loading");
  try {
    const video = await setupCamera();
    video.play();
  } catch(e) {
    console.log("Error:", e);
    loading.textContent = "Error loading the camera on your device. Sorry!";
    return;
  }

  // cocoSsd is provided by an earlier JS include.
  cocoSsd.load().then(model => {
    loading.textContent = "Model loaded! Look for the detections below.";
    console.log("Loaded the cocoSsd model.");
    detectSingleFrame(model, video);
  });
}


/**
 * Run detection on a single frame, drawing the results on the canvas.
 */
function detectSingleFrame (model, video) {

  const canvas  = document.getElementById("canvas");
  const ctx     = canvas.getContext("2d");

  canvas.width  = videoWidth;
  canvas.height = videoHeight;

  function detectionLoop () {
    model.detect(video).then(predictions => {
      // Draw image
      ctx.save();
      ctx.drawImage(video, 0, 0, videoWidth, videoHeight);
      
      // Now, draw bounding-boxes
      predictions.forEach(prediction => {
        var [x, y, width, height] = prediction["bbox"];
        var thing                 = prediction["class"];
        var score                 = prediction["score"];

        score = Math.round(score*100)/100;

        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x + width, y);
        ctx.lineTo(x + width, y + height);
        ctx.lineTo(x, y+height);
        ctx.lineTo(x, y);
        ctx.stroke();

        ctx.fillStyle = "#ffffff";
        ctx.fillRect(x, y - 20, width, 20);

        ctx.fillStyle = "black";
        ctx.font = "12px PT Mono";
        ctx.fillText(thing + " (" + score + ")", x, y - 10);
      });

      ctx.restore();
    });

    requestAnimationFrame(detectionLoop);
  }

  detectionLoop();
}
