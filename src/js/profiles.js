function startVideo (person) {
  toggleVideo(person, true);
}

function showImage (person) {
  toggleVideo(person, false);
}

function toggleVideo (person, on) {
  v = "none";
  i = "block";

  vid = document.getElementById(person + "-video");

  if (on) {
    v = "block";
    i = "none";
    vid.play();
  }

  vid.style.display = v;
  document.getElementById(person + "-image").style.display = i;
}
