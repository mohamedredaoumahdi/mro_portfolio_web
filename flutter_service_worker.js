'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "55fa38dad798d5cb5556571a33f38b23",
"version.json": "cc1fa9cce5af273c0909d105387fee89",
"index.html": "9358bf193ed5c994b5203200eed4d540",
"/": "9358bf193ed5c994b5203200eed4d540",
"main.dart.js": "facff482402aeb5a6051af72d1357775",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "4a4af18e3f1558fd40b090b1cfa663c9",
".git/config": "2d7f0b579738457d8bdecfcd85ef7803",
".git/objects/0c/6fb31f58693b7d698820ae45a8da03a9273b1c": "d084c8aa1cc1221a6d865bb4768463ca",
".git/objects/0c/1bb0685218bc4b86088747974bb4158257d78b": "c98a56726b984cb167e62dfd2db4856b",
".git/objects/68/ada6801319c7737e6c91bada590438696c217e": "fff6809357e011cec2a8dcc30b84714f",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "7a2beaf557655dfe4d49f90a155f8001",
".git/objects/6f/30ac2f380bbe11644ff090e8aee5e2ab73492e": "e42f3be2144dc3deb2e9bc377116af7e",
".git/objects/35/6c260a06e2977fdadebeabdaec393269295085": "fc987d7f69141765cfaf111475a21316",
".git/objects/3c/069e3ccb8771932da96f794b5cb80a18332fff": "6d39e2948d413f2cf4de165693865764",
".git/objects/56/3283ae4adacae86e5f97c635a353a8d27b4876": "9bd6961aa19d014ab491bb3c5deec632",
".git/objects/3d/f29120d8e80579c5770ff162a91bbf73ea47e3": "627a1c43e92e4965658514c616c52370",
".git/objects/94/e0a065cd0bc136dae1df1e60537391bede733f": "b0967a52fb0a833c4e9d1c9299bace5b",
".git/objects/05/adb347614ac448998070548eb7d88ce8470a35": "8ba674e48c25337659450f694672aa1a",
".git/objects/9d/5d8a5d925bd4d5e6824f5c692d02767f353c26": "ad871df62dfa8ffabc60c1634238c15a",
".git/objects/9d/3b0928ce0eecb25959bda0ffb0ed3387121dc4": "0e468ab26168906a1a4187ed804b300d",
".git/objects/ac/a2f66e3e7b989584d93d650ff6803096a58877": "c0fcc56e80e04b6c5081ae86cf6d283c",
".git/objects/ac/d4b85ce7b30ef9f075b7dae1b686af4d86d1c2": "28945d4109ee306944b0f6e678529000",
".git/objects/ad/71d92bb1c4dd516e10bc0f5d7c446ea7df6023": "e7c13bd93e25bc99780ac43139caf47d",
".git/objects/d0/6eb5351b6d0a0631c7003aac32686937b30ffc": "57a383da78a63c755414f673e8835fba",
".git/objects/da/a3d06656edfbf8fd2f87164a9db7821cc8333d": "24787cead6ce63d5f570285bf3e88539",
".git/objects/d1/ae9a1562d76154daa0ab930d311083c7033cf4": "a0eaa700c1d581816737a4defc765921",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "5a9f3522bf38ba5dd54f15a0f75cb0d7",
".git/objects/ab/acb90e87612ee09bff8c8bde95beb9f234fe11": "1338e3bb264667d7e5477de076bb75c0",
".git/objects/e5/56a67f750881ffbec598de813cbe52d0c17e37": "4613f4f0860a704be810a39a83ed0432",
".git/objects/e2/49245dbb76d0a69411623aec0698e275b1efd7": "21e91f1aa4e91193db2f5441e946ee47",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "01d8a507be49f15714be4d17b6947e52",
".git/objects/ee/14a6d0b16906ca8313161f343e68b77dc615ac": "ab4f52c34a4be08368fad57e97b8d0f5",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "aa30b45014e5ab878c26ecce9ea89743",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "fb2ee964a7fc17b8cba79171cb799fa3",
".git/objects/ed/9e7e5ddd4a17ea6364f72a3e98acf242b6bb8d": "4d71def732c5ffc15d4dfd7169548df2",
".git/objects/45/240da9c0796edf11840795cf29db4e36744041": "02dc643d8e02009bf61ef67cec582d7b",
".git/objects/28/a40520e5337fed0a9a23941ae8a6adecfe7f79": "e7f44c54ede6e3d0a14a9a97fe455821",
".git/objects/7b/1cc48e95f8273ee39c27ac2efcaee887a3077f": "9efea8684ee04efee69835016212520e",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "0e7fbd1f8845cbeb2cdbf944a84ebaee",
".git/objects/8a/8b10ac96d4332beee870dedf3b450228c0b179": "df8db570b554b32f6859999ca348d468",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "b25b26893b8f92a4f583677ba27f0a7f",
".git/objects/19/26c804b95bcd44835689b0ddf1ac10d0b7a805": "e0517f55b4782dfed64a5d18f4f72d85",
".git/objects/26/55364713d5bfaf0eff8c7ea399f73bfe9a9b0f": "b4e2763ff099d6c8d81279ad7de0787d",
".git/objects/72/beb002fa2e0884b3ab0bc03262ec8db1d5c823": "bee0676792465f8beb0fec3a73b6e057",
".git/objects/43/6c982ff3209357305892181e61565d1e01d439": "e50ca0d56e44141329217c4f50ee1a12",
".git/objects/88/5cce940659818f97bbb4bd4363478461027967": "4d65321926f2d552771da5ebeccfcba8",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e35fdc55764d9ed14315f6ff50093ab3",
".git/objects/9f/33c4871736aed54a4be73ef853163b7b4a9d01": "749628d8fb6fe170265707e24afdbc9e",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "9524d053d0586a5f9416552b0602a196",
".git/objects/91/9453b0d1cd6c488d13bdad5b309608ec1cd342": "1d69ba06b5b88ccb375dcf9063e66886",
".git/objects/96/3f88f64fd8fe2b331fef9294c9a27893a15952": "b04a59f31431daab79755c395d96ce9f",
".git/objects/5e/607cc9b0d8916253a21c8d00633cbc1b720b22": "6a2031788732318789fd43c397070eb8",
".git/objects/5e/bf37944a56f2b5e479e3858392c6e9030da2da": "bfd14d13850066655518c7b7f8c8a70b",
".git/objects/6d/439254ba665d57f149a71e10e46ab8cbc75b90": "cf141eeb67bd6a2e875c0d655a1f5b52",
".git/objects/39/966d4735aa39e89bb7aebede85111cf73344e9": "251e29aeb7ea9cb462f32952d2a8af64",
".git/objects/99/d14f6c36c741adf0e822d503153bfb477f5f06": "ccbc0e4f197c1709c45d859f5f361ab5",
".git/objects/0a/50dbef4f108bc83341e52371859862d816c586": "b2a7e874ec228ff5434bf04ba4b3ce7c",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "9dbf5b01e391c548c8343be8d1d4b04e",
".git/objects/a0/5bb63aa690fbd30a57c8a7934630945e42bd40": "01c2670041e2ecc74e6d482a0195d5c5",
".git/objects/a0/e129589f0de2cfe1d8ce51824340d604f80833": "c317a55422a71c0ad29922451f2bd9fe",
".git/objects/b1/eedfa199f50a59b8cd7add1dc95a5393a70e5f": "6f08ba4b49a125f064b163b9de87d40f",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "b0c549c0aed479932cf26d094f76630e",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "936bdc921e2d2af84e1b88a53c8fc956",
".git/objects/a6/a5506a10bc7f8b0ce65b2ddea0f3c41af74861": "c1c6bd7483eca2a3c364201c5602a00f",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "9de9f2c6fa0aea6ee34b79162e9fc361",
".git/objects/a1/8c6c696b18fcf3377482c387069cafa31e6430": "672e915e672446fec7ff0df2a8600e05",
".git/objects/ef/5745c35d3cf7d97c0f8a8968f0a083e5e6ce99": "b0f5d6572bc59866344cef8e2d40cba5",
".git/objects/ea/2a8e8879c5a64bdb9130655ad580b067ff39ce": "c8792350019ae3c464015979bd01ff88",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "c3694958e54483a81b3e32ab9f84ece2",
".git/objects/cb/9a378ad9f1c1ec3da7892a240d70c326c10c88": "971582e3ad0d7cbaf3636202d7fa94b7",
".git/objects/e0/98bd8a9fcf99789b8740d872cfda3af7288b0e": "a65210f3eeffbc9bc9125573859495f1",
".git/objects/e0/18ced1612860d625d540e60d35d336a26b2f64": "767b24fac4ba2159aa45ac044bf349d0",
".git/objects/79/9d0eca4feb77979d2b53c071655f448c89a07f": "b290fcbce247badf2e874146aa42a1b2",
".git/objects/79/b7aad8ac35e54c0d70943c2888034e84745eb1": "a24e971d0062953da8cfac44561b0d5c",
".git/objects/2d/1c3b53f5a28c4327b55de6d12c3a9d6432627e": "28e58399411ac594658e9799fe2f77b1",
".git/objects/2d/40c4e5be35ede8206b9f4d3ffec1b3fc3efccc": "d49b54ce168a35954c23286f059f27a3",
".git/objects/41/82b8840b6649fc9ccaf8ecf921298cd0f8e676": "fe7b7b46affb38538092ee52bef38888",
".git/objects/85/8772b80bcc076e8f302d5309eef1dab4a7998d": "883890ffc531541586da1e7e0ce6bd08",
".git/objects/82/a84b9bcf670ef73341893e41161da651d73a76": "062a9eaa1de8d5c8e59dab529ff96bc2",
".git/objects/47/fe1b26d50d34ed621f63b5e36094551ccc5190": "b76913e93c8e147bceba2dade30c84fd",
".git/objects/13/35367e91a0d7554b913cd5de55de01d6f50f03": "776755024c1db816070c333e028ff812",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "50aee4a5d76263c5d62d01812d6a1d01",
".git/logs/refs/heads/main": "435331f25e52f2bc611976bc597eb8f9",
".git/logs/refs/remotes/origin/main": "dca3175040dffd2275fb65026b185d5e",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/main": "77fa4d96d036aa2e0ed7418587b517f9",
".git/refs/remotes/origin/main": "77fa4d96d036aa2e0ed7418587b517f9",
".git/index": "642b994df37917d2567b2bf99ffd0ee4",
".git/COMMIT_EDITMSG": "4191be86803767c26186dd0305bd69e5",
"assets/AssetManifest.json": "4190e1076a60a7e70244398043651ce1",
"assets/NOTICES": "2c6a7b38ad3b4600ac763e91bc7ff0d8",
"assets/FontManifest.json": "f3a0a47a063385e2ce4e188ebdd734e0",
"assets/AssetManifest.bin.json": "09ff9d9112193bfb313208d6261b1947",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/youtube_player_iframe/assets/player.html": "dc7a0426386dc6fd0e4187079900aea8",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "048497a12f98b7a84a7d52b56be392d0",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "1b7a498076c7965067737b7109c0d83b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "f97ceca47ec563146c584a1a5711a4c2",
"assets/fonts/MaterialIcons-Regular.otf": "7d069f987084f7e1a0db333a780b626f",
"assets/assets/icons/maintenance.png": "e76ae5d54afd7605f41f350981415ce7",
"assets/assets/icons/ui_design.png": "2aaf10a580e77149ac1b3cb18551a1fe",
"assets/assets/icons/api.png": "47cc5317c8a2bc70b5ee51e92e83377e",
"assets/assets/icons/mobile_dev.png": "32a744f8c6575300b7091fb25401fab2",
"assets/assets/fonts/JetBrainsMono-Bold.ttf": "3aba5b9b33104e426ed11fe6b5789753",
"assets/assets/fonts/JetBrainsMono-Regular.ttf": "a0147b5ab9e4946e81879aef45313def",
"assets/assets/fonts/JetBrainsMono-Light.ttf": "822a285e32f16f218ae505dc3c51cae7",
"assets/assets/fonts/JetBrainsMono-Medium.ttf": "9200bf1d80f2f4947b496a2e6ab2e224",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "bd0e768fef31e76b4c56f7caa4efdd90",
"canvaskit/canvaskit.js.symbols": "7e9893036c3fa7843429f59531f3b942",
"canvaskit/skwasm.wasm": "f65759a23ad54e185d6a3f17817b16ca",
"canvaskit/chromium/canvaskit.js.symbols": "a1fea26b10a418991dc0fdd670d0a105",
"canvaskit/chromium/canvaskit.js": "417c635e514296a337033bbd95ba8332",
"canvaskit/chromium/canvaskit.wasm": "4bed638ac5457a6ee18834aeaab3deb0",
"canvaskit/skwasm_st.js.symbols": "327a3060925e525407f4f2747a4712d6",
"canvaskit/canvaskit.js": "d9252a0c6a6498261f19267314e95a47",
"canvaskit/canvaskit.wasm": "5ddabdaf5ff10d64d4f06fbd522f4ff1",
"canvaskit/skwasm_st.wasm": "809674c831d83f7f9c71d9dd93771403"};
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
