'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/assets/images/paopizzax.png": "5f540312670bd81fa1e0e3204d566ca8",
"assets/assets/images/paobaguetefrancesacomqueijox.png": "68e4f120a24e0a3294de9b5c348803d7",
"assets/assets/images/paodealhodacasapicantex.png": "49b93c8e4712f23e53b6bec8eb5a3065",
"assets/assets/images/paofrancesx.png": "74c35270edfda85b2df243578520c37d",
"assets/assets/images/paodequeijocoquetelx.png": "29f32ef93f5becdfa3292d6244685ee2",
"assets/assets/images/roscacaseiraleiteempo.jpg": "13a01ac29a651e15942221fca12caca7",
"assets/assets/images/paotatux.png": "f5f876c266958a8cddeac358671cf5a6",
"assets/assets/images/paosamaritanox.png": "4ef4d99cda09ad8340ba251e70222ca4",
"assets/assets/images/folhapedido.png": "903d9421007683d0a7bcca2464063c9b",
"assets/assets/images/paobaguetefrancesagergelim.jpg": "7694bb8e555fdb6e5072e66fb0a2e780",
"assets/assets/images/logobahamas.jpg": "af0a714835d2a5383235e9db1e46b36f",
"assets/assets/images/minipaofrancesgergelim.jpg": "21a1dbb86884aa27d0b43f42e86d8064",
"assets/assets/images/paisefilhos.jpg": "b39ee4e52590361644a5ed9a11eb7424",
"assets/assets/images/sanduichebahamas.jpg": "7d117dd6c643052cd41341389caa4e90",
"assets/assets/images/roscafofinhatemperada.jpg": "7af26b89995f01fa3bb73554225aa9b7",
"assets/assets/images/paofrancesqueijo.jpg": "245a48afbae9e81d9f997d2693e4a3f5",
"assets/assets/images/torradafibrasdealho.jpg": "02d72149b94cfc57d81c90ddb105f5ae",
"assets/assets/images/paodealhodacasapicante.jpg": "9453106bbe288437bd423ca3134dbb41",
"assets/assets/images/paobambino.jpg": "ae79f5b9d1c712a619061d6d40a858b8",
"assets/assets/images/paobaguetefrancesaqueijo.jpg": "cca419646e6e9db12550824f30b74228",
"assets/assets/images/paobambinox.png": "1f24139f45096fb3843b48f706d1a12d",
"assets/assets/images/minipaomartarochax.png": "86e71217ca26152e5b53e3fa436edaff",
"assets/assets/images/roscacocoequeijo.jpg": "929e3b4e36612520413aaabda47a9d23",
"assets/assets/images/biscoitodequeijox.png": "4c41fd340e6038a5ca4f76d9127461db",
"assets/assets/images/paodequeijotradicional.jpg": "e4b20af3cac8f30d51ff9093b4f894f3",
"assets/assets/images/latas.jpg": "fe3f96d7a09ef89f1a8ad628d35ad1b3",
"assets/assets/images/climatica.jpg": "43de91634b4148fae12197e3ff14d308",
"assets/assets/images/sanduichefofinho.png": "1be22ce7bd5615a1d44eac8b55b0c77f",
"assets/assets/images/mapaentregas.png": "18df289625edd1d102e9dde164930719",
"assets/assets/images/martminas2.jpg": "c5011c02ef12f524fc95f8393fd69e36",
"assets/assets/images/etiquetavalidade.png": "f7a3ad36b125b93f1531f3c996189fae",
"assets/assets/images/torradadealho.jpg": "f79b6592b2e4b41eb9f1de7d9cdd1080",
"assets/assets/images/paofrancesfibras.jpg": "f11c8331faf7d767b9c1d0a516f917d3",
"assets/assets/images/roscacaseiracoco.jpg": "b0020351b2edb9b8c720d11caad65c6c",
"assets/assets/images/paodocecaracol.jpg": "035e7fdb036b190eb5779fc535519da0",
"assets/assets/images/paotatu.jpg": "3b7beacffb359116249a90f90e90314d",
"assets/assets/images/baguetefrancesax.png": "82b4318bf1d1d8cd88510b06f70bd982",
"assets/assets/images/paofrancespanhocax.png": "b329672fb88f17bc761910807acbbc0b",
"assets/assets/images/catalogo.png": "a412f8e5630ebe2aa72beaedd2495da0",
"assets/assets/images/roscacaseira.jpg": "8346d9d55a52d3335c41b43a46a02d5a",
"assets/assets/images/profiterolesbrigadeiro.jpg": "51315ce4bb146ac89c02eb5ef80f5582",
"assets/assets/images/paosamaritano.jpg": "bd8f75934a188885dc263e452ddf493b",
"assets/assets/images/paopararabanada.jpg": "f99d702b40c70e81583c507331a9d070",
"assets/assets/images/torradaintegral.jpg": "3bdbf44a472d1bf695b965d0fe4ccd98",
"assets/assets/images/paocaseirinho.jpg": "beeafed69b53ef51d91409c5ff55b78f",
"assets/assets/images/paobaguete.jpg": "0eb1a1326da641c5a6a881f5efc53a1b",
"assets/assets/images/paodealhodacasa.jpg": "42bbdcdceddc3625b2672033e1821a69",
"assets/assets/images/integral.jpg": "9c46e1007d1d7afb894e6e6c08ccace2",
"assets/assets/images/minipaosonhochocolatex.png": "295568837d141f183d0f03e342a2211b",
"assets/assets/images/paodocecaracolx.png": "5bad77bf1821c315a12c73f4297394f9",
"assets/assets/images/minipaosonhochocolate.jpg": "d3bb5e1a5e03de1efec054dbf23a144c",
"assets/assets/images/Mart-Minas.jpg": "24074a1b36daa4de4b2c3e89a57c2fd4",
"assets/assets/images/minipaomartarocha.jpg": "9a33ed8359bae59c14ca12b68895be26",
"assets/assets/images/profiterolesbrigadeirobranco.jpg": "b4ad0195077a75d011d2ee0488386e6e",
"assets/assets/images/paodocecomprido.jpg": "99fb5511b113f0e6569c828121be0d9b",
"assets/assets/images/biscoitopolvilho.jpg": "fd77a86a265f89bdf54015e1a545808a",
"assets/assets/images/paodequeijotradicionalx.png": "885bc7d56d3c74e5e363ea5dba04651d",
"assets/assets/images/paobagutefrancesax.png": "d30ab80558e0ac3e985973ddae4c8c6c",
"assets/assets/images/paomilho.jpg": "725bd62bd7968dba8c4dc92acc717409",
"assets/assets/images/paofrances.jpg": "4e0010da037f58c1bc211ca673fe744e",
"assets/assets/images/paobaguetefrancesacomgergelimx.png": "61aa275bc0dba38e7907acf316f7b5d4",
"assets/assets/images/panhoca.jpg": "c64dec74e50690e292284fb81c2a6c9a",
"assets/assets/images/paofrancesfibrasx.png": "26484b404a106828be37d6b702f4f42d",
"assets/assets/images/minipaosonho.jpg": "5dc130066c291a899c30de91bbd5618c",
"assets/assets/images/bh.jpg": "da67b49f99276de6cc05e1ede7a7c29e",
"assets/assets/images/logo_ajudai.png": "4f201c267e10cc7d38f9b9f0c04f15c9",
"assets/assets/images/rabanadaassadax.png": "72870b7b261d8d5d36a53d7fd4f86485",
"assets/assets/images/rabanadaassada.jpg": "6fde51007030c80d7ed55e5265cae446",
"assets/assets/images/insumos.png": "aa092e3ac94bde3c5b007a5dcb14dc1b",
"assets/assets/images/baguetefrancesa.jpg": "a7242c38f0b863b6ef9dc503dc7bcaea",
"assets/assets/images/paofofinhox.png": "0e7f52e20e5ac7e98fbacf72ea5cbdf1",
"assets/assets/images/sanduichefofinho.jpg": "a581c81f11c76602086e0e273c97a3a3",
"assets/assets/images/paofofinho.jpg": "649c2d014dd07a042e4cdeda1923c915",
"assets/assets/images/minipaosonhox.png": "1b14da56369738f3204ddfaf6a52e296",
"assets/assets/images/torradacomum.jpg": "91a02e3419bde0b6d6eac373177ef937",
"assets/assets/images/roscacocoequeijox.png": "9f3d0a88027d57d1e4aef372a6fa1e61",
"assets/assets/images/fornos.jpg": "6c4a5a58c88bdc735237ff8062ecbc6d",
"assets/assets/images/torradadealhopicante.jpg": "7cd28e83edec3e2a2fe686afb8e8f19c",
"assets/assets/images/paodoceferradura.jpg": "04e34b06eab917d284d4291d3f67d4fe",
"assets/assets/images/bahamas.jpg": "351362f0f7b55050a39cd5769bc52734",
"assets/assets/images/biscoitopolvilhox.png": "377f5807887e6dad0c636ea4ce485c28",
"assets/assets/images/torradadealhointegral.jpg": "1e3f3afa41bdc8366c7e23af9a2f7ffa",
"assets/assets/images/paodequeijocoquetel.jpg": "cb98c2363fb3639a69dca73f360cefdd",
"assets/assets/images/Logo%2520StockOne.png": "5bb9a9c3d1c18e8c5f12dc9549138415",
"assets/assets/images/biscoitodequeijo.jpg": "ea812310dea9dea8ef967cb2f788abef",
"assets/assets/images/paofrancescomqueijox.png": "e4b6308aac300163c02df53a38dbf331",
"assets/assets/images/roscafofinhatemperadax.png": "ed12d917d143e2d1d1698d8f5ea39ffc",
"assets/assets/images/paopararabanadax.png": "b7359fd951d428e0076fb687354bc533",
"assets/assets/images/baguetefrancesaqueijo.jpg": "eda7c692829f0f3ca7c0981425e8c093",
"assets/assets/images/StockOnesf.png": "7b2dfea411ee39947d55324bcae2a579",
"assets/assets/images/paopizza.jpg": "51fd46e84b36653a1baaa89a403a4aa8",
"assets/assets/images/torradafibras.jpg": "8dcf698496696db3989f262cbbb99c18",
"assets/assets/images/paocaseirinhox.png": "f117e32b18bae22a193e4eea1680af7b",
"assets/assets/images/baguetefrancesacomqueijox.png": "791ca54cf07c2a535d84b55797b40035",
"assets/assets/images/freezers.jpg": "67a1332b7fe887e42aa2293712eeb17e",
"assets/assets/images/paodoceferradurax.png": "739b1b1e1e1e623868d8830c994f60e3",
"assets/assets/images/codigos.png": "f0d5cddd4cd47c7c0df38c69cd90cfd0",
"assets/assets/images/baixas2371.png": "ec83e5eb8c820f817d7d7dd142ba6cd1",
"assets/assets/images/baixas8949.png": "52dec04b87420966c02fbc7f2202fa20",
"assets/assets/images/paodealhodacasax.png": "f26c29cd9f6d6308c1bba06be357a8fa",
"assets/assets/images/profiterolesdocedeleite.jpg": "67c42bc3c5b91f764bdc04c225ffe392",
"assets/assets/images/armarios.jpg": "c9592a4c4d792f9a153ef1552c9ff84c",
"assets/fonts/MaterialIcons-Regular.otf": "636af89a75aee480750751fb6c2e0b61",
"assets/AssetManifest.bin": "e373cbb9d237b40589d4b214bb0027d1",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "bbc8aeb835c9afd97a67462434cd5148",
"assets/NOTICES": "dd223d62033b4fd0be19c9e4de1c30da",
"assets/packages/wakelock_plus/assets/no_sleep.js": "74499cf34f37daae14b51e3a23cd9f7a",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"version.json": "612e4e55171a338fd7e6799af11cbbf3",
"index.html": "639ce0d830c077df193b0f42eb3ba50d",
"/": "639ce0d830c077df193b0f42eb3ba50d",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"flutter_bootstrap.js": "77fd20d36dd673c441a5a5f1b0e6e9e3",
"manifest.json": "0b91fe1774db1570d031630b15d3aa46",
"main.dart.js": "18398ac9a3056c255b97b9d83fb1699b"};
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
