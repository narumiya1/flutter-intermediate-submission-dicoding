import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/post_story_m.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';
import 'package:submission_intermediate/provider/post_story_p.dart';
import 'package:submission_intermediate/routes/page_manager.dart';
import 'package:submission_intermediate/utils/helpers.dart';
import 'package:image_picker/image_picker.dart';

class PostStoryPage extends StatefulWidget {
  final VoidCallback onSuccessAddStory;

  const PostStoryPage({super.key, required this.onSuccessAddStory});

  @override
  State<PostStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<PostStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Story")),
      body: ChangeNotifierProvider<PostStoryProvider>(
        create: (context) => PostStoryProvider(ApiService()),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 54),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 140,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _selectImage(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_selectedImage != null)
                            Opacity(
                              opacity: 0.8,
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  child: Image.file(_selectedImage!)),
                            ),
                          Text(
                            "Select Image Gallery",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    child: TextFormField(
                      controller: _descriptionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description!';
                        }
                        return null;
                      },
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<PostStoryProvider>(
                    builder: (context, provider, _) {
                      switch (provider.state) {
                        case ResultState.hasData:
                          print(provider.message);
                          afterBuildWidgetCallback(() {
                            context.read<PageManager>().returnData(true);
                            widget.onSuccessAddStory();
                            showSnackBar(context, provider.message);
                          });
                          break;
                        case ResultState.error:
                        case ResultState.noData:
                          print(provider.message);
                          showSnackBar(context, provider.message);

                          break;
                        default:
                          break;
                      }

                      return ElevatedButton(
                        onPressed: () => _onUploadPressed(provider),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text("Upload")],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _onUploadPressed(PostStoryProvider provider) {
    if (_formKey.currentState?.validate() == true && _selectedImage != null) {
      PostStoryRequest request = PostStoryRequest(
          description: _descriptionController.text, photo: _selectedImage!);
      provider.addStory(request);
    }
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
}
