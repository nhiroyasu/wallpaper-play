 (function () {
   // Create a scale monitoring system for video tags
   window.videoAspectSystem = {
     observer: null,
     observerActive: false,
     resizeTimeout: null,

     // Calculate and apply scale based on the video element's aspect ratio
     adjustVideoScale: function (video) {
       if (video && video.tagName === "VIDEO") {
         // Apply base style settings
         video.style.transformOrigin = "center center";

         // Adjust directly if video is already loaded, otherwise adjust on load
         if (video.videoWidth && video.videoHeight) {
           this.calculateAndApplyScale(video);
         } else {
           // Adjust when metadata is loaded
           video.addEventListener(
             "loadedmetadata",
             () => {
               this.calculateAndApplyScale(video);
             },
             { once: true }
           );
         }

         // Also adjust when video size changes (e.g., fullscreen toggle)
         video.addEventListener("resize", () => {
           this.calculateAndApplyScale(video);
         });
       }
     },

     // Calculate and apply scale to the video
     calculateAndApplyScale: function (video) {
       try {
         // Video size and aspect ratio
         const videoWidth = video.videoWidth;
         const videoHeight = video.videoHeight;
         const videoAspect = videoWidth / videoHeight;

         // Window size and aspect ratio
         const windowWidth = window.innerWidth;
         const windowHeight = window.innerHeight;
         const windowAspect = windowWidth / windowHeight;

         // Calculate scale value
         const small = Math.min(windowAspect, videoAspect);
         const large = Math.max(windowAspect, videoAspect);
         const scale = large / small;
         const formattedScale = scale.toFixed(3);

         // Apply the calculated scale to the video
         video.style.scale = scale;

         // Success message
         console.log(`Scale ${formattedScale} applied to video`);

         return scale;
       } catch (error) {
         console.error(
           `Error occurred during scale calculation: ${error.message}`
         );
         return null;
       }
     },

     // Apply adjustments to all video elements
     adjustAllVideos: function () {
       const videos = document.getElementsByTagName("video");
       for (let i = 0; i < videos.length; i++) {
         this.adjustVideoScale(videos[i]);
       }
       return videos.length;
     },

     // Initialize Mutation Observer
     initObserver: function () {
       if (this.observerActive) {
         this.observer.disconnect();
       }

       const self = this;
       this.observer = new MutationObserver(function (mutations) {
         for (let mutation of mutations) {
           if (mutation.addedNodes) {
             for (let node of mutation.addedNodes) {
               // When a video tag is directly added
               if (node.tagName === "VIDEO") {
                 self.adjustVideoScale(node);
               }

               // When an element containing video tags is added
               if (node.getElementsByTagName) {
                 const nestedVideos = node.getElementsByTagName("video");
                 for (let video of nestedVideos) {
                   self.adjustVideoScale(video);
                 }
               }
             }
           }
         }
       });

       // Start monitoring if body exists
       if (document.body) {
         this.observer.observe(document.body, {
           childList: true,
           subtree: true,
         });
         this.observerActive = true;
         console.log("Video aspect ratio observer started");
       } else {
         console.log("Body not ready, waiting for DOMContentLoaded");
       }

       // Set up window resize handling
       window.addEventListener("resize", () => {
         // Debounce to prevent consecutive resize events
         clearTimeout(this.resizeTimeout);
         this.resizeTimeout = setTimeout(() => {
           this.adjustAllVideos();
           console.log("Window resized, videos adjusted");
         }, 200); // 200ms debounce
       });
     },
   };

   // Initialize based on page loading state
   if (document.readyState === "loading") {
     document.addEventListener("DOMContentLoaded", function () {
       window.videoAspectSystem.initObserver();
       window.videoAspectSystem.adjustAllVideos();
       console.log("Video aspect system initialized on DOMContentLoaded");
     });
   } else {
     window.videoAspectSystem.initObserver();
     window.videoAspectSystem.adjustAllVideos();
     console.log("Video aspect system initialized immediately");
   }
 })();
