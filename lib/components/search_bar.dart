import 'package:flutter/material.dart';

@deprecated
class SearchBar extends StatelessWidget {

  buildTextField() {
    return TextField(
      decoration: InputDecoration(
        icon: Icon(Icons.search, color: Color(0xffe5e5e5),size: 30,),
        hintText: '搜索',
        hintStyle: TextStyle(color: Color(0xffe5e5e5)),
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      child: buildTextField(),
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Color(0xfff6f7f7f7)
      ),
    );
  }

}