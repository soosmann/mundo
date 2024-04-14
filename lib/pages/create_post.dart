import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/post_preview.dart';

class CreatePostView extends StatefulWidget {
  final Post post;

  const CreatePostView({Key? key, required this.post}) : super(key: key);

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  TextEditingController titleInputController = TextEditingController();

  UserDataManager dataSaver = UserDataManager();
  PostDataManager postDataManager = PostDataManager();
  
  /// func to call image select and open gallery
  Future selectImageFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;
      final imageTemp = File(image.path);
      setState(() => widget.post.addImage(imageTemp));
    } on PlatformException catch(e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// post gets a new text element at first
  @override
  void initState(){
    super.initState();
    widget.post.addText("");
  }

  /// icon to continue, firstly, delete all unnecessary elements\
  /// then check if post has text and image, if so, navigate to post preview
  Widget _appBar() {
    return AppBar(
      title: Text(widget.post.title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.done),
          onPressed: () {
            setState(() { 
              widget.post.deleteNotNecessaryElements();
            });
            
            if (widget.post.getHasTextAndImage()){
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => PostPreviewView(post: widget.post))
              );
            }
          },
        ),
      ],
    );
  }

  /// custom entry field for post content
  Widget _entryField(
    String title,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    int maxLines
  ){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10), 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width-20,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: 1,
            maxLines: maxLines,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            cursorColor: Theme.of(context).textTheme.labelLarge!.color,
            decoration: InputDecoration(
              labelText: title,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
          ),
        ),
      )
    );
  }

  /// displays the content of the post as a reorderable list
  Widget _postContent(){
    return Expanded(
      child: ReorderableListView(
        onReorder: (oldIndex, newIndex) => setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = widget.post.postElements.removeAt(oldIndex);
          widget.post.postElements.insert(newIndex, item);

          widget.post.updateElementPositions();
        }),
        children: <Widget>[
          for (var postElement in widget.post.postElements)
            if (postElement is PostText)
              ListTile(
                key: ObjectKey(postElement.position),
                subtitle: /*entryField(
                  context, 
                  380, 
                  null, 
                  const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  "Schreib hier über deine Erlebnisse ", 
                  TextEditingController(text: postElement.text), 
                  5,
                  innerPadding: const EdgeInsets.fromLTRB(5, 0, 5, 30),
                  onChanged: (value) => postElement.text = value,),*/
                _entryField(
                  "Schreib hier über deine Erlebnisse...", 
                  TextEditingController(text: postElement.text), 
                  (value) => postElement.text = value,
                  5
                ),
                trailing:Column(
                  children: [
                    ReorderableDragStartListener(
                      index: postElement.position,
                      child: const Icon(Icons.drag_handle),
                    ),
                    const SizedBox(height: 5,),
                    InkWell(
                      onTap: () {
                        setState(() {
                          widget.post.deleteText(postElement);
                        });
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red, 
                        )
                    )
                  ],
                ) 
              )
            else if (postElement is PostImage)
              ListTile(
                key: ObjectKey(postElement.position),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  key: ValueKey(postElement.position),
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        for (var element in widget.post.postElements){
                          if (element is PostImage){
                            element.isMainImage = false;
                          }
                        }
                        postElement.isMainImage = true;
                        widget.post.mainImageIndex = postElement.position;
                      });
                    },
                    child: Container(
                      decoration: postElement.isMainImage 
                        ? BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 10,
                            ),
                          ) 
                        : null,
                      child: Image.file(
                        postElement.imageFile,
                        width: MediaQuery.of(context).size.width-60,
                        height: MediaQuery.of(context).size.width-60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                trailing: Column(
                  children: [
                    ReorderableDragStartListener(
                      index: postElement.position,
                      child: const Icon(Icons.drag_handle),
                    ),
                    const SizedBox(height: 5,),
                    InkWell(
                      onTap: () {
                        setState(() {
                          widget.post.deleteImage(postElement);
                        });
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red, 
                        )
                    )
                  ],
                ) 
              )
        ],
      ),
    );
  }

  /// buttons to add text or image to the post
  Widget _addPostElementButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor
          ),
          onPressed: () {
            setState(() {
              widget.post.addText("");
            });
          },
          child: const Icon(Icons.subject),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor
          ),
          onPressed: () {
            selectImageFromGallery();
          },
          child: const Icon(Icons.add_a_photo),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            entryField(
              context, 
              MediaQuery.of(context).size.width-20,
              MediaQuery.of(context).size.height*0.06, 
              const EdgeInsets.fromLTRB(0, 10, 0, 10), 
              "Titel", 
              titleInputController, 
              1,
              onChanged: (value) => setState(() => widget.post.changeTitle(value)),
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              inputFormatters: [LengthLimitingTextInputFormatter(50)]
            ),
            _postContent(),
            _addPostElementButtons()
          ]
        ),
      )
    );
  }
}