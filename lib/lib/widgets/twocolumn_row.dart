import 'package:flutter/cupertino.dart';

class TwoColumnTable extends StatelessWidget {
  final List<String> leftColumn;
  final List<String> rightColumn;

  TwoColumnTable({required this.leftColumn, required this.rightColumn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < leftColumn.length; i++)
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: DefaultTextStyle(
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemBlue),
                            child: Text(leftColumn[i]),
                          )),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: CupertinoColors.systemGrey),
                        child: Text(rightColumn[i]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}