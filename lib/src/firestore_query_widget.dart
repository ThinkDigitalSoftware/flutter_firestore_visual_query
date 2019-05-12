import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firestore_visual_query/src/bloc/bloc.dart';
import 'package:flutter_firestore_visual_query/src/bloc/query_bloc.dart';
import 'package:flutter_firestore_visual_query/src/bloc/query_state.dart';
import 'package:flutter_firestore_visual_query/src/enums.dart';

class FirestoreQueryWidget extends StatefulWidget {
  final Firestore firestore;

  const FirestoreQueryWidget({Key key, @required this.firestore})
      : super(key: key);

  @override
  _FirestoreQueryWidgetState createState() => _FirestoreQueryWidgetState();
}

class _FirestoreQueryWidgetState extends State<FirestoreQueryWidget> {
  QueryBloc queryBloc;
  TextEditingController _collectionController;
  TextEditingController _fieldController;
  TextEditingController _queryController;
  dynamic isEqualTo;
  dynamic isLessThan;
  dynamic isLessThanOrEqualTo;
  dynamic isGreaterThan;
  dynamic isGreaterThanOrEqualTo;
  dynamic arrayContains;
  bool isNull;
  bool _boolValue = true;

  bool enableQuery = false;
  String _selectedWhereCondition;
  String _selectedValueType = "string";

  @override
  void initState() {
    BlocSupervisor().delegate = LoggingDelegate();
    queryBloc = QueryBloc(firestore: widget.firestore);
    _collectionController = TextEditingController()
      ..addListener(() {
        if (collection.isNotEmpty && !enableQuery) {
          setState(() {
            enableQuery = true;
          });
        } else if (collection.isEmpty && enableQuery) {
          setState(() {
            enableQuery = false;
          });
        }
      });
    _fieldController = TextEditingController();
    _queryController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    queryBloc.dispose();
    super.dispose();
  }

  String get collection => _collectionController.text;

  String get field => _fieldController.text;

  String get query => _queryController.text;

  dynamic convert(dynamic value) {
    if (_selectedValueType == Types.string)
      return value as String;
    else if (_selectedValueType == Types.number)
      return value as int;
    else if (_selectedValueType == Types.boolean)
      return _boolValue;
    else
      return dynamic;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              AppBar(
                title: Text(
                  "Firestore Query",
                  style: TextStyle(color: Colors.white),
                ),
                iconTheme: IconThemeData(color: Colors.white),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: enableQuery
                        ? () {
                            switch (_selectedWhereCondition) {
                              case WhereCondition.arrayContains:
                                arrayContains = convert(query);
                                break;
                              case WhereCondition.isEqualTo:
                                isEqualTo = convert(query);
                                break;
                              case WhereCondition.isGreaterThan:
                                isGreaterThan = convert(query);
                                break;
                              case WhereCondition.isGreaterThanOrEqualTo:
                                isGreaterThanOrEqualTo = convert(query);
                                break;
                              case WhereCondition.isLessThan:
                                isLessThan = convert(query);
                                break;
                              case WhereCondition.isLessThanOrEqualTo:
                                isLessThanOrEqualTo = convert(query);
                                break;
                              case WhereCondition.isNull:
                                isNull = true;
                                break;
                            }
                            queryBloc.dispatch(NewQueryEvent(
                                collection: collection,
                                field: field,
                                isEqualTo: isEqualTo,
                                isLessThan: isLessThan,
                                isLessThanOrEqualTo: isLessThanOrEqualTo,
                                isGreaterThan: isGreaterThan,
                                isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
                                arrayContains: arrayContains,
                                isNull: isNull));
                          }
                        : null,
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //collection TextField
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: _collectionController,
                        decoration: InputDecoration(
                            labelText: "Collection",
                            isDense: true,
                            border: OutlineInputBorder(),
                            helperText: "Collection"),
                      ),
                    ),
                    //field TextField
                    TextField(
                      controller: _fieldController,
                      decoration: InputDecoration(
                        hintText: "Where",
                        labelText: "Field",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    QueryConditionDropdown(
                      selectedOption: _selectedWhereCondition,
                      onChanged: (String value) {
                        setState(() {
                          _selectedWhereCondition = value;
                        });
                      },
                    ),
                    if (_selectedWhereCondition != null &&
                        _selectedWhereCondition != WhereCondition.isNull)
                      Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 4.0, right: 8.0, top: 10),
                            child: DropdownButton<String>(
                              value: _selectedValueType,
                              items: [
                                for (String option in Types.values)
                                  DropdownMenuItem<String>(
                                    child: Text(option),
                                    value: option,
                                  )
                              ],
                              onChanged: (String value) {
                                setState(() {
                                  _selectedValueType = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                              child: buildQueryWidget(
                                  selectedValueType: _selectedValueType))
                        ],
                      )
                  ],
                ),
              )
            ],
          ),
        ),
        BlocBuilder<QueryEvent, QueryState>(
          bloc: queryBloc,
          builder: (context, snapshot) {
            return Expanded(
              child: ResultsCard(
                documents: snapshot.results,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildQueryWidget({@required String selectedValueType}) {
    switch (selectedValueType) {
      case Types.string:
      case Types.number:
        return TextField(
          keyboardType:
              selectedValueType == Types.number ? TextInputType.number : null,
          controller: _queryController,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
        );
      case Types.boolean:
        return DropdownButton<bool>(
          value: _boolValue,
          items: [
            DropdownMenuItem(
              value: true,
              child: Text("true"),
            ),
            DropdownMenuItem(
              value: false,
              child: Text("false"),
            ),
          ],
          onChanged: (bool value) {
            setState(() {
              _boolValue = value;
            });
          },
        );
      default:
        return Container();
    }
  }
}

class QueryConditionDropdown extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const QueryConditionDropdown({
    Key key,
    @required this.selectedOption,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 8.0),
          child: Text(
            "Condition:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: selectedOption,
            hint: Text(
              "Select a query",
              style: TextStyle(fontSize: 14),
            ),
            items: [
              for (var option in WhereCondition.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(fontSize: 14),
                  ),
                )
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class ResultsCard extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  const ResultsCard({Key key, this.documents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(border: Border(top: BorderSide())),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Results"),
            ),
            Expanded(
              child: Card(
                elevation: 8,
                child: ListView.builder(
                  itemCount: documents.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    var document = documents[index];
                    Map data = document.data;
                    return ExpansionTile(
                      title: Text(document.reference.path),
                      children: <Widget>[
                        for (var entry in data.entries)
                          DataTile(data: entry, level: 0)
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DataTile extends StatelessWidget {
  final dynamic data;
  final int index;

  /// how deep this node is in the nested tree. Used for indenting.
  final int level;

  const DataTile(
      {Key key, @required this.data, this.index, @required this.level})
      : super(key: key);

  Text errorText(dynamic value) => Text(
      "A widget for ${value.runtimeType} has not been accounted for yet\n $value",
      style: TextStyle(color: Colors.red));

  @override
  Widget build(BuildContext context) {
    if (data is MapEntry) {
      var value = data.value;
      if (value is Map) {
        return mapWidget(key: data.key, value: data.value);
      } else if (value is String ||
          value is int ||
          value == null ||
          value is DocumentReference) {
        return Text(
          "${data.key}: ${value is DocumentReference ? value.path : value}",
          textAlign: TextAlign.start,
        );
      } else if (value is List)
        return ListView.builder(
          itemCount: value.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return DataTile(
              data: value[index],
              index: index,
              level: this.level + 1,
            );
          },
        );
      else
        return errorText(value);
    } // if it's not a map entry or a List, but a final value...
    else if (data is String ||
        data is int ||
        data is bool ||
        data == null ||
        data is DocumentReference) {
      return Container(
        height: 15,
        child: Row(
          children: <Widget>[
            if (index != null)
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.grey,
                  padding: EdgeInsets.all(8),
                  child: Text(index.toString())),
            Text(
              data is DocumentReference ? data.path : data,
            ),
          ],
        ),
      );
    } else if (data is Map) {
      return mapWidget(value: data);
    }
    return errorText(data);
  }

  Widget mapWidget({String key = "", @required Map value}) {
    return Padding(
      padding: EdgeInsets.only(left: 4.0 * level),
      child: ExpansionTile(
        title: Text(key),
        children: <Widget>[
          for (var entry in value.entries)
            Container(
              decoration: BoxDecoration(
                  border:
                      Border(left: BorderSide(color: Colors.red, width: 2))),
              child: DataTile(
                data: entry,
                level: this.level + 1,
              ),
            )
        ],
      ),
    );
  }
}
