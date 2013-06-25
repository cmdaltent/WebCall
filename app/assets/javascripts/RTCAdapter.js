var RTCPeerConnection = null;
var getUserMedia = null;
var attachMediaStream = null;
var reattachMediaStream = null;
var webrtcDetectedBrowser = null;

if (navigator.mozGetUserMedia) {
	console.log("This appears to be Firefox");

	webrtcDetectedBrowser = "firefox";

	// The RTCPeerConnection object.
	RTCPeerConnection = mozRTCPeerConnection;

	// The RTCSessionDescription object.
	RTCSessionDescription = mozRTCSessionDescription;

	// The RTCIceCandidate object.
	RTCIceCandidate = mozRTCIceCandidate;

	// Get UserMedia (only difference is the prefix).
	// Code from Adam Barth.
	navigator.getUserMedia = navigator.mozGetUserMedia.bind(navigator);

	// Attach a media stream to an element.
	attachMediaStream = function(element, stream) {
		console.log("Attaching media stream");
		element.mozSrcObject = stream;
		element.play();
	};

	reattachMediaStream = function(to, from) {
		console.log("Reattaching media stream");
		to.mozSrcObject = from.mozSrcObject;
		to.play();
	};

	// Fake get{Video,Audio}Tracks
	MediaStream.prototype.getVideoTracks = function() {
		return [];
	};

	MediaStream.prototype.getAudioTracks = function() {
		return [];
	};
} else if (navigator.webkitGetUserMedia) {
	console.log("This appears to be Chrome");

	webrtcDetectedBrowser = "chrome";

	// The RTCPeerConnection object.
	RTCPeerConnection = webkitRTCPeerConnection;

	// Get UserMedia (only difference is the prefix).
	// Code from Adam Barth.
	navigator.getUserMedia = navigator.webkitGetUserMedia.bind(navigator);

	// Attach a media stream to an element.
	attachMediaStream = function(element, stream) {
		element.src = webkitURL.createObjectURL(stream);
	};

	reattachMediaStream = function(to, from) {
		to.src = from.src;
	};

	// The representation of tracks in a stream is changed in M26.
	// Unify them for earlier Chrome versions in the coexisting period.
	if (!webkitMediaStream.prototype.getVideoTracks) {
		webkitMediaStream.prototype.getVideoTracks = function() {
			return this.videoTracks;
		};
		webkitMediaStream.prototype.getAudioTracks = function() {
			return this.audioTracks;
		};
	}

	// New syntax of getXXXStreams method in M26.
	if (!webkitRTCPeerConnection.prototype.getLocalStreams) {
		webkitRTCPeerConnection.prototype.getLocalStreams = function() {
			return this.localStreams;
		};
		webkitRTCPeerConnection.prototype.getRemoteStreams = function() {
			return this.remoteStreams;
		};
	}
} else {
	console.log("Browser does not appear to be WebRTC-capable");
}

function preferOpus(sdp) {
	var sdpLines = sdp.split('\r\n');

	// Search for m line.
	for (var i = 0; i < sdpLines.length; i++) {
		if (sdpLines[i].search('m=audio') !== -1) {
			var mLineIndex = i;
			break;
		}
	}
	if (mLineIndex === null)
		return sdp;

	// If Opus is available, set it as the default in m line.
	for (var i = 0; i < sdpLines.length; i++) {
		if (sdpLines[i].search('opus/48000') !== -1) {
			var opusPayload = extractSdp(sdpLines[i], /:(\d+) opus\/48000/i);
			if (opusPayload)
				sdpLines[mLineIndex] = setDefaultCodec(sdpLines[mLineIndex], opusPayload);
			break;
		}
	}

	// Remove CN in m line and sdp.
	sdpLines = removeCN(sdpLines, mLineIndex);

	sdp = sdpLines.join('\r\n');
	return sdp;
}

function extractSdp(sdpLine, pattern) {
	var result = sdpLine.match(pattern);
	return (result && result.length == 2) ? result[1] : null;
}

// Set the selected codec to the first in m line.
function setDefaultCodec(mLine, payload) {
	var elements = mLine.split(' ');
	var newLine = new Array();
	var index = 0;
	for (var i = 0; i < elements.length; i++) {
		if (index === 3)// Format of media starts from the fourth.
			newLine[index++] = payload;
		// Put target payload to the first.
		if (elements[i] !== payload)
			newLine[index++] = elements[i];
	}
	return newLine.join(' ');
}

// Strip CN from sdp before CN constraints is ready.
function removeCN(sdpLines, mLineIndex) {
	var mLineElements = sdpLines[mLineIndex].split(' ');
	// Scan from end for the convenience of removing an item.
	for (var i = sdpLines.length - 1; i >= 0; i--) {
		var payload = extractSdp(sdpLines[i], /a=rtpmap:(\d+) CN\/\d+/i);
		if (payload) {
			var cnPos = mLineElements.indexOf(payload);
			if (cnPos !== -1) {
				// Remove CN payload from m line.
				mLineElements.splice(cnPos, 1);
			}
			// Remove CN line in sdp
			sdpLines.splice(i, 1);
		}
	}

	sdpLines[mLineIndex] = mLineElements.join(' ');
	return sdpLines;
}