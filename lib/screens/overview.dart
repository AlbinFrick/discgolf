import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Overview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        body: SafeArea(
      child: Container(
        color: Colors.grey[700],
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: Firestore.instance
                .collection('games')
                .document(args['gameid'])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.exists) {
                List<DataColumn> dataColumns = List<DataColumn>();
                DataColumn holes = DataColumn(
                    label: Center(
                  child: Text(
                    "Hål",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ));
                dataColumns.add(holes);
                args['players'].forEach((player) {
                  DataColumn playerCol = DataColumn(
                      label: Center(
                    child: Text(
                      player['firstname'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ));
                  dataColumns.add(playerCol);
                });

                List<DataRow> dataRows = List<DataRow>();
                int length;
                snapshot.data['players'].forEach((id, player) {
                  length = snapshot.data['players'][id]['holes'].length;
                });

                for (int i = 1; i <= length; i++) {
                  List<DataCell> cells = List<DataCell>();
                  cells.add(DataCell(
                      Center(
                          child: Text(
                        i.toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                      placeholder: true));

                  snapshot.data['players'].forEach((id, player) {
                    print(player['holes']);
                    cells.add(DataCell(
                        Center(
                          child: Text(
                            player['holes'][i.toString()]['throws'].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        placeholder: true));
                  });
                  dataRows.add(DataRow(cells: cells));
                }

                return DataTable(
                  columns: dataColumns,
                  rows: dataRows,
                );
              }
              return Container(
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }
}
