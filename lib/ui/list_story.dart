import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/stories_m.dart';
import 'package:submission_intermediate/data/pref/token.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';
import 'package:submission_intermediate/provider/story_p.dart';
import 'package:submission_intermediate/routes/page_manager.dart';
import 'package:submission_intermediate/utils/helpers.dart';
import 'package:submission_intermediate/widgets/card_list.dart';

class ListStoryPage extends StatefulWidget {
  final VoidCallback onLogoutSucces;
  final Function(String?) onStoryClickd;
  final VoidCallback onPostStoryClicked;

  const ListStoryPage({
    super.key,
    required this.onLogoutSucces,
    required this.onStoryClickd,
    required this.onPostStoryClicked,
  });
  @override
  State<ListStoryPage> createState() => _ListStoryPageState();
}

class _ListStoryPageState extends State<ListStoryPage> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    afterBuildWidgetCallback(() async {
      final pageManager = context.read<PageManager>();
      final shoudRefresh = await pageManager.waitForResult();

      if (shoudRefresh) {
        _refreshKey.currentState?.show();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Shoot Story"),
          actions: [
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                var tokenPref = Token();
                tokenPref.setToken("");

                widget.onLogoutSucces();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: widget.onPostStoryClicked,
          child: const Icon(Icons.add),
        ),
        body: ChangeNotifierProvider<ListStoryProvider>(
          create: (context) => ListStoryProvider(ApiService()),
          builder: (context, child) =>
              Consumer<ListStoryProvider>(builder: (context, provider, _) {
            switch (provider.state) {
              case ResultState.loading:
                return const Center(child: CircularProgressIndicator());
              case ResultState.hasData:
                return RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: () => provider.getAllStories(),
                  child: _listStories(context, provider.stories),
                );
              case ResultState.error:
              case ResultState.noData:
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(provider.message),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => {provider.getAllStories()},
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text('Refresh')],
                        ),
                      ),
                    ],
                  ),
                );
              default:
                return Container();
            }
          }),
        ));
  }

  Widget _listStories(BuildContext context, List<Story> stories) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      itemCount: stories.length,
      itemBuilder: (_, index) {
        
        print(index);

        return CardList(
          story: stories[index],
          onStoryClicked: () => widget.onStoryClickd(stories[index].id),
        );
      },
    );
  }
}
