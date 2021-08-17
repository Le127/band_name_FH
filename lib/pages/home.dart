import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:band_names/services/socket_service.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    //Escucha desde el servidor el mensaje "active-bands"
    //Se castea a List el payload para poder trabajar con el metodo map
    socketService.socket.on("active-bands", (payload) {
      this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off("active-bands");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("BandNames", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red[300]),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, int index) => _bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        onPressed: addNewBand,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        socketService.socket.emit("delete-band", {"id": band.id});
      },
      background: Container(
        padding: EdgeInsets.only(left: 20),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.delete),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text("${band.votes}", style: TextStyle(fontSize: 20)),
        onTap: () {
          socketService.socket.emit(
            "vote-band",
            {"id": band.id},
          );
        },
      ),
    );
  }

  addNewBand() {
    final TextEditingController textController = TextEditingController();

    if (Platform.isAndroid || Platform.isWindows) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("New band name:"),
            content: TextField(controller: textController),
            actions: [
              MaterialButton(
                child: Text("Add"),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
              ),
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("New band name"),
        content: CupertinoTextField(controller: textController),
        actions: [
          CupertinoDialogAction(
            child: Text("Add"),
            isDefaultAction: true,
            onPressed: () => addBandToList(textController.text),
          ),
          CupertinoDialogAction(
            child: Text("Dismiss"),
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void addBandToList(String bandName) {
    if (bandName.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);

      socketService.socket.emit(
        "add-band",
        {"name": bandName},
      );

      Navigator.pop(context);
    }
  }
}
