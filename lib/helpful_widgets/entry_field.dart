import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// function to create a custom MiMundo entry field
Widget entryField(
  BuildContext context,
  double? width,
  double? height,
  EdgeInsets outerPadding,
  String title,
  TextEditingController controller,
  int maxLines,
  {
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    bool obscureText = false,
    EdgeInsets? innerPadding,
    List<TextInputFormatter>? inputFormatters
  }
){
  return Padding(
    padding: outerPadding, 
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        padding: innerPadding, //const EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme!.primary,
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          minLines: 1,
          maxLines: maxLines,
          //maxLength: 10,
          textAlignVertical: TextAlignVertical.center,
          textAlign: TextAlign.left,
          cursorColor: Theme.of(context).textTheme.labelLarge!.color,
          decoration: InputDecoration(
            labelText: title,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ),
    ),
  );
}