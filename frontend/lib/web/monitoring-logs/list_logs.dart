import 'package:flutter/material.dart';
import 'package:frontend/models/monitoring_log.dart';
import 'package:intl/intl.dart';

class ListLogs extends StatefulWidget {
  final List<MonitoringLog> logs;
  const ListLogs({super.key, required this.logs});

  @override
  ListLogsState createState() => ListLogsState();
}

class ListLogsState extends State<ListLogs> {
  late List<MonitoringLog> filteredLogs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredLogs = widget.logs;
    _searchController.addListener(() {
      setState(() {
        filteredLogs = widget.logs.where((log) {
          return log.type
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              log.content
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              log.createdAt
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: PaginatedDataTable(
              columns: const [
                DataColumn(label: Text("Log type")),
                DataColumn(label: Text("Content")),
                DataColumn(label: Text("Date")),
              ],
              source: LogsDataSource(filteredLogs),
              rowsPerPage: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class LogsDataSource extends DataTableSource {
  final List<MonitoringLog> logs;
  LogsDataSource(this.logs);

  @override
  DataRow getRow(int index) {
    final log = logs[index];
    return DataRow(cells: [
      DataCell(Text(log.type)),
      DataCell(Text(log.content)),
      DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(log.createdAt)))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => logs.length;
  @override
  int get selectedRowCount => 0;
}
