'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "0b91fe1774db1570d031630b15d3aa46",
"index.html": "639ce0d830c077df193b0f42eb3ba50d",
"/": "639ce0d830c077df193b0f42eb3ba50d",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "116f2c70008b2f95dee8252d66efbfc9",
"assets/assets/images/paodocecaracol.jpg": "035e7fdb036b190eb5779fc535519da0",
"assets/assets/images/logobahamas.jpg": "af0a714835d2a5383235e9db1e46b36f",
"assets/assets/images/paobaguetefrancesagergelim.jpg": "80f7992960bb1d936ad85bbad235c5f2",
"assets/assets/images/Logo%2520StockOne.png": "5bb9a9c3d1c18e8c5f12dc9549138415",
"assets/assets/images/paodealhodacasapicante.jpg": "196a7076816075a6ff866b8d59ad3c84",
"assets/assets/images/freezers.jpg": "67a1332b7fe887e42aa2293712eeb17e",
"assets/assets/images/paobambino.jpg": "62ebe062829ea49c45850ba5b4c2813b",
"assets/assets/images/paofrancesqueijo.jpg": "023c700d827b5edd2fd24e1d77fb54a2",
"assets/assets/images/paodealhodacasa.jpg": "e979b8a127eabf14c76d3fa3d43580f9",
"assets/assets/images/torradacomum.jpg": "15218e094d5330ab92a09357c985b6f4",
"assets/assets/images/paofrancesfibras.jpg": "1258d9a967bff650423303bbf724958f",
"assets/assets/images/baixas8949.png": "52dec04b87420966c02fbc7f2202fa20",
"assets/assets/images/bh.jpg": "da67b49f99276de6cc05e1ede7a7c29e",
"assets/assets/images/panhoca.jpg": "993566c82f7fa85c999c5c69d3184e3e",
"assets/assets/images/paofrances.jpg": "4edb190dff5f6f52fa2d3af324a6b353",
"assets/assets/images/paomilho.jpg": "5be8d5f585dbfe0bd53fc3b17bca32a5",
"assets/assets/images/minipaosonho.jpg": "7a40e647fdf62a3e290bc4f9657908f8",
"assets/assets/images/folhapedido.png": "903d9421007683d0a7bcca2464063c9b",
"assets/assets/images/paofofinho.jpg": "2117e5951b02c4485d3af27158e1b00e",
"assets/assets/images/minipaomartarocha.jpg": "af23e10b622480cee99fc05ca2e7cdc6",
"assets/assets/images/roscafofinhatemperada.jpg": "bfe9538f3091b3182f145649c0c49b39",
"assets/assets/images/rabanadaassada.jpg": "2cf5a1171c7c0e5ecc00bb25d4f196e1",
"assets/assets/images/paodequeijocoquetel.jpg": "2cf815f7ef34fc47fb4938d7d92027c6",
"assets/assets/images/torradaintegral.jpg": "3bdbf44a472d1bf695b965d0fe4ccd98",
"assets/assets/images/paopararabanada.jpg": "d2c9dffc8725fb1090bc9a170e3ab5f6",
"assets/assets/images/paosamaritano.jpg": "b45428c9c34d1a8990d084011b1f9f64",
"assets/assets/images/minipaofrancesgergelim.jpg": "21a1dbb86884aa27d0b43f42e86d8064",
"assets/assets/images/logo_ajudai.png": "4f201c267e10cc7d38f9b9f0c04f15c9",
"assets/assets/images/StockOnesf.png": "7b2dfea411ee39947d55324bcae2a579",
"assets/assets/images/profiterolesbrigadeirobranco.jpg": "b4ad0195077a75d011d2ee0488386e6e",
"assets/assets/images/paopizza.jpg": "90b2560b786a5dea2b1815621d37a8ab",
"assets/assets/images/integral.jpg": "9c46e1007d1d7afb894e6e6c08ccace2",
"assets/assets/images/minipaosonhochocolate.jpg": "cdf5ca099acef9d67144c4111ee1ab95",
"assets/assets/images/torradafibrasdealho.jpg": "d41e7906be9238c7537b6440305db065",
"assets/assets/images/armarios.jpg": "c9592a4c4d792f9a153ef1552c9ff84c",
"assets/assets/images/profiterolesdocedeleite.jpg": "67c42bc3c5b91f764bdc04c225ffe392",
"assets/assets/images/paocaseirinho.jpg": "beeafed69b53ef51d91409c5ff55b78f",
"assets/assets/images/sanduichefofinho.jpg": "006d588cbc87ba0b0dc39f25c89bb747",
"assets/assets/images/roscacaseira.jpg": "28d2fe50be412240a3c74012a9716221",
"assets/assets/images/paodequeijotradicional.jpg": "e4b20af3cac8f30d51ff9093b4f894f3",
"assets/assets/images/paisefilhos.jpg": "b39ee4e52590361644a5ed9a11eb7424",
"assets/assets/images/fornos.jpg": "6c4a5a58c88bdc735237ff8062ecbc6d",
"assets/assets/images/etiquetavalidade.png": "f7a3ad36b125b93f1531f3c996189fae",
"assets/assets/images/biscoitodequeijo.jpg": "859717d72528b5c05d3fd0c528e29a5a",
"assets/assets/images/torradadealho.jpg": "402c56f9e08a60372fff8d6d56f19683",
"assets/assets/images/climatica.jpg": "43de91634b4148fae12197e3ff14d308",
"assets/assets/images/baguetefrancesaqueijo.jpg": "1df6c009c1edfaede50f68c15eeaff73",
"assets/assets/images/bahamas.jpg": "351362f0f7b55050a39cd5769bc52734",
"assets/assets/images/torradafibras.jpg": "b1c1f37c34edebdc647419ac678009e6",
"assets/assets/images/paotatu.jpg": "3b7beacffb359116249a90f90e90314d",
"assets/assets/images/roscacaseiraleiteempo.jpg": "3cf38a2ade180fce45f0b31814b9c9d4",
"assets/assets/images/paodoceferradura.jpg": "04e34b06eab917d284d4291d3f67d4fe",
"assets/assets/images/insumos.png": "aa092e3ac94bde3c5b007a5dcb14dc1b",
"assets/assets/images/paobaguete.jpg": "81ce6e2ba6c13eee81ce79fe2d38cbd5",
"assets/assets/images/baguetefrancesa.jpg": "121811ef29c81cff7fa678f5e74c15d1",
"assets/assets/images/mapaentregas.png": "18df289625edd1d102e9dde164930719",
"assets/assets/images/biscoitopolvilho.jpg": "bc11da478b1462b71831f4cf881a65fe",
"assets/assets/images/catalogo.png": "a412f8e5630ebe2aa72beaedd2495da0",
"assets/assets/images/paodocecomprido.jpg": "99fb5511b113f0e6569c828121be0d9b",
"assets/assets/images/roscacaseiracoco.jpg": "1b135677531b5ad385bcf352a4793140",
"assets/assets/images/roscacocoequeijo.jpg": "411022ad3b7e655163e69af9cae5e218",
"assets/assets/images/profiterolesbrigadeiro.jpg": "51315ce4bb146ac89c02eb5ef80f5582",
"assets/assets/images/codigos.png": "14f37842c266a2be35d38b596d51b5c7",
"assets/assets/images/torradadealhointegral.jpg": "1e3f3afa41bdc8366c7e23af9a2f7ffa",
"assets/assets/images/latas.jpg": "fe3f96d7a09ef89f1a8ad628d35ad1b3",
"assets/assets/images/paobaguetefrancesaqueijo.jpg": "da3d5d239ec48b91850a03ed8a55bce3",
"assets/assets/images/sanduichebahamas.jpg": "bb78f7adf97624879a21503c932a0146",
"assets/assets/images/baixas2371.png": "ec83e5eb8c820f817d7d7dd142ba6cd1",
"assets/fonts/MaterialIcons-Regular.otf": "9b96d4a48c4ea90081131a04262ae57c",
"assets/NOTICES": "fda614ce7a1e84e92b159511ed4444f4",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin": "fc679baead69e32eb4cc8997cde61350",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "3afb13fbe61ed6a5dd9b047a891641b2",
"version.json": "b20f3c67e37e8bd8b72a3e698fc10d27",
"main.dart.js": "3d7b0285a0039f592763ca8289fc4bd4"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
