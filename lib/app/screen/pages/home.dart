import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:moist/app/components/home_page_tile.dart';
import 'package:moist/app/components/textfield/search/search_textfield.dart';
import 'package:moist/app/screen/pages/search.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/helper/format.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  Map<dynamic, dynamic> homeData = {};
  List songs = [];
  Logger logger = Logger();
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    Box homeCache = Hive.box('homeCache');
    songs = await homeCache.get('homeData', defaultValue: []);

    DateTime time = await homeCache.get('lastUpdated');

    var timeDiff = time.difference(DateTime.now()).inHours;

    if (timeDiff <= 2) {
      logger.e('Skip fetching home data $timeDiff');
      setState(() {});
      return;
    }

    setState(() {
      if (songs.isEmpty) {
        _isLoading = true;
      }
    });

    logger.w('fetching home data');

    await fetchHomeData();

    await Hive.box('homeCache').putAll({
      'homeData': songs,
      'lastUpdated': DateTime.now(),
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchHomeData() async {
    songs.clear();
    homeData = await SaavnAPI().fetchHomePageData();
    Map formatedData = await FormatResponse.formatPromoLists(homeData);
    Map modules = formatedData['modules'];
    modules.forEach((key, value) {
      songs.add({
        'title': value['title'],
        'items': formatedData[key],
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Hero(
          tag: 'search',
          child: SearchTextField(
            controller: _searchController,
            readOnly: true,
            onTap: () {
              pushScreenWithNavBar(context, const SearchPage());
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _getData(),
        child: !_isLoading
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    const Gap(12),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: songs
                          .map((item) => HomePageTile(sectionIitem: item))
                          .toList(),
                    ),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
