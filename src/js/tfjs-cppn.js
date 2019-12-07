class CppnNetwork {

  constructor (outputWidth, outputHeight, latentVector) {
    this.net              = null;
    this.walking          = false;
    this.outputWidth      = outputWidth;
    this.outputHeight     = outputHeight;
    this.latentVector     = latentVector;
    this.latentDimensions = this.latentVector.length;
  }

  async loadModel (modelUrl) {
    console.log("Loading model from=", modelUrl);
    this.net = await tf.loadLayersModel(modelUrl);
    console.log(this.net);
    console.log("Model loaded!");
  }


  /** */
  forward () {
    console.log("Going forward!");
    tf.tidy( () => {
      // Build input
      var data = this.buildInput(this.outputWidth, this.outputHeight, this.latentVector);
      const output = this.net.predict(data);
      this.renderEverything(output);
    } );
  }


  /** */
  buildInput (w, h, z) {
    return tf.tidy(() => {
      const x = tf.linspace(-1, 1, w);
      const y = tf.linspace(-1, 1, h);

      const xx = tf.matMul( tf.ones  ([h, 1]), x.reshape([1, w]) )
      const yy = tf.matMul( y.reshape([h, 1]), tf.ones  ([1, w]) );

      var data   = tf.stack( [xx, yy], -1 );

      // Add in the "z" stuff.
      const zvec = tf.tensor1d(z);
      const ones = tf.ones( [ h, w, 1] );
      data       = tf.concat( [data, tf.mul(ones, zvec)], 2 );

      // Add in batch dimension. Note, for some 
      // reason, the batch dimension is at the front.
      data = data.reshape( [1].concat( data.shape ) );
      return data;
    });
  }


  /** */
  renderEverything (output) {
    // Render it in the final neuron
    const node = document.getElementById("final-neuron");
    this.drawPicture(node, output.dataSync(), this.outputWidth, this.outputHeight, 0, 0);
  }


  /** */
  drawPicture (node, data, w, h, i, j) {
    const ctx = node.getContext("2d");
    const img = new ImageData(w, h);

    for (let x = 0; x < w; x++) {
      for (let y = 0; y < h; y++) {
        const ix = (y*w + x) * 4;

        const iv = (y*w + x) * 3;
        img.data[ix + 0] = Math.floor(255 * data[iv + 0]);
        img.data[ix + 1] = Math.floor(255 * data[iv + 1]);
        img.data[ix + 2] = Math.floor(255 * data[iv + 2]);
        img.data[ix + 3] = 255;
      }
    }

    ctx.putImageData(img, i*w, j*w);
  }


  /** */
  resetModel () {
    if ( this.net ) {
      tf.dispose(this.net);
    }

    tf.disposeVariables();

    this.net = this.buildNetwork();

    this.forward();
  }


  /** */
  buildNetwork () {
    var first      = true;
    var index      = 0;
    var h          = this.outputHeight;
    var w          = this.outputWidth;
    var zdim       = this.latentDimensions;
    var inputShape = undefined;

    // console.log("h=", h, "w=", w, "zdim=", zdim);

    return tf.tidy( () => {
      const net = tf.sequential();

      this.layers.forEach( l => {
        var init = tf.initializers.randomNormal({ mean: 0, stddev: 1, seed: l.seed });
        index += 1;

        if (first) {
          first = false;
          inputShape = [h, w, 2 + zdim];
        } else {
          inputShape = undefined;
        }

        const spec = { filters:           l.units
                     , activation:        l.activationFunction
                     , kernelSize:        1
                     , inputShape:        inputShape
                     , kernelInitializer: init
                     , biasInitializer:   init
                     , name:              "layer-" + index + "-conv2d"
                     } 

        net.add(tf.layers.conv2d(spec));
      });

      // TODO: Make customisable
      // Final layer
      var init = tf.initializers.randomNormal({ mean: 0, stddev: 1, seed: 1 });
      net.add( tf.layers.conv2d(
        { filters: 3
        , activation: "sigmoid"
        , kernelSize: 1
        , kernelInitializer: init
        , biasInitializer : init
        , name: "final-output"
        } ) );

      return net;
    } );
  }


  /** */
  randomLatent (n) {
    function getRandomArbitrary (min, max) {
      return Math.random() * (max - min) + min;
    }

    var z = [];

    for ( var i = 0; i < n; i++ ) {
      var zi = getRandomArbitrary(-1, 1);
      z.push(zi);
    }

    return z;
  }


  /** */
  // startRandomWalk () {
  //   const MAX = 100;

  //   function stepTowards (z1, z2, currentStep) {
  //     function f () {
  //       if ( cppn.walking === false ) {
  //         return;
  //       }

  //       if ( currentStep === 0 ) {
  //         z1 = z2;
  //         z2 = cppn.randomLatent(cppn.modelSpec.latentDimensions);
  //         requestAnimationFrame( stepTowards(z1, z2, MAX -1) );
  //         return;
  //       }

  //       var z = [];
  //       const t = currentStep / MAX;
  //       for (var i = 0; i < z1.length; i++ ){
  //         const zi = z1[i] * t + z2[i] * (1-t);
  //         z.push( zi );
  //       }

  //       cppn.modelSpec.latentVector = z;
  //       app.ports.setLatentVector.send(cppn.modelSpec.latentVector);
  //       latent.updateCirclePositions(z);
  //       cppn.forward();
  //       requestAnimationFrame( stepTowards(z1, z2, currentStep - 1) );
  //     }

  //     return f;
  //   }

  //   var z1       = this.modelSpec.latentVector;
  //   var z2       = this.randomLatent(this.modelSpec.latentDimensions);
  //   this.walking = true;

  //   requestAnimationFrame( stepTowards(z1, z2, MAX - 1) );
  // }


  /** */
  stopRandomWalk () {
    this.walking = false;
    this.forward();
  }


  /** */
  downloadBig () {
    tf.tidy( () =>  {
      // Let's only think about squares for now.
      const size    = 1000;
      const allData = this.buildInput(size, size, this.latentVector);

      //  size = 500
      //  |z|  = 10
      //
      // then:
      //  allData.shape = [1, 500, 500, 12];

      const parts = size / this.outputWidth;
      const node  = document.getElementById("big-output");

      for (var i = 0; i < parts; i++) {
        for (var j = 0; j < parts; j++) { 
          var w  = i * this.outputWidth;
          var h  = j * this.outputWidth;
          var wn = (i+1) * this.outputWidth;
          var hn = (j+1) * this.outputWidth;

          var slice = allData.stridedSlice
            ( [0, w, h, 0]
            , [allData.shape[0], wn, hn, allData.shape[allData.shape.length-1]]
            , [1, 1, 1, 1]
            );

          var d = this.net.predict(slice).dataSync();
          this.drawPicture(node, d, this.outputWidth, this.outputWidth, j, i);
        }
      }

      var e = document.getElementById("link");
      e.innerHTML = "";
      var link  = document.createElement("a");
      link.href = node.toDataURL();
      link.download = "cppn-playground-big-image.png";
      e.appendChild(link);
      link.click();

    });
  }
}
