import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:gnanou_nam/screens/command_screen.dart';
import 'package:gnanou_nam/widgets/navigation_drawer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imgList = [
    'images/L1.jpg',
    'images/L2.jpg',
    'images/L3.jpg',
  ];
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    _initBannerAd();
    super.initState();
  }

  _initBannerAd() async {
    _bannerAd = BannerAd(
        size: AdSize.mediumRectangle,
        adUnitId: BannerAd.testAdUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            print("voici l'erreur: $error");
            ad.dispose();
          },
        ),
        request: const AdRequest());

    await _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      drawer: NavigationDrawer(),
      floatingActionButton: buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            stretch: true,
            expandedHeight: MediaQuery
                .of(context)
                .size
                .height * 0.26,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
              ],
              background: Image.asset(
                'images/L.jpg',
                fit: BoxFit.cover,
              ),
            ),
            leading: Builder(
                builder: (context) =>
                    IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(
                              Icons.menu,
                              color: mainColor,
                            )))),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 10,
              ),
              buildCarrousel(),
              _isAdLoaded
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(
                    ad: _bannerAd,
                  ),
                ),
              )
                  : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              buildContact()
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildCarrousel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          viewportFraction: 0.9,
          enlargeCenterPage: true,
        ),
        items: imgList
            .map((item) =>
            ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                child: Stack(
                  children: <Widget>[
                    Image.asset(item, fit: BoxFit.cover, width: 1000.0),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget buildContact() {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        height: MediaQuery
            .of(context)
            .size
            .height * 0.2,
      ),
      const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Nous contacter...',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          )),
      Positioned(
        right: 0,
        bottom: MediaQuery
            .of(context)
            .size
            .height * 0.06,
        child: InkWell(
          onTap: () async {
            const number = '+22898270654';
            launch('tel://$number');
          },
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.35,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.06,
            decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: const Center(
                child: Icon(
                  FontAwesome.phone,
                  size: 30,
                  color: Colors.white,
                )),
          ),
        ),
      ),
      Positioned(
        bottom: MediaQuery
            .of(context)
            .size
            .height * 0.06,
        child: InkWell(
          onTap: () async {
            const whatsappNumber = '+22898270654';
            const whatsappUrlAndroid =
                "whatsapp://send?phone=" + whatsappNumber + "&text=Bonjour, ";
            var whatsappUrlIos =
                "https://wa.me/$whatsappNumber?text=${Uri.parse("Bonjour, ")}";

            if (Platform.isIOS) {
              await launch(whatsappUrlIos, forceSafariVC: false);
            } else {
              await launch(whatsappUrlAndroid);
            }
          },
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.35,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.06,
            decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: const Center(
                child: Icon(
                  FontAwesome.whatsapp,
                  size: 30,
                  color: Colors.white,
                )),
          ),
        ),
      ),
    ]);
  }

  Widget buildFab() {
    return FloatingActionButton.extended(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      foregroundColor: Colors.white,
      backgroundColor: mainColor,
      icon: const Icon(Icons.add),
      label: const Text('Commander', style: TextStyle(fontSize: 16),),
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CommandScreen()));
      },
    );
  }
}
