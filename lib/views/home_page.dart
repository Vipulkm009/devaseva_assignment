import 'dart:convert';

import 'package:devaseva_assignment/blocs/internet_bloc/internet_bloc.dart';
import 'package:devaseva_assignment/models/food_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  // List<Food> foods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable ListView'),
      ),
      body: BlocConsumer<InternetBloc, InternetState>(
        listener: (context, state) {
          if (state is InternetGained) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Internet Connected...',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Internet Disconnected...',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
            ));
          }
        },
        builder: (context, internetState) {
          if (internetState is InternetGained) {
            return FutureBuilder(
                future: loadData(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Food>> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    final foods = snapshot.data!;
                    print(foods.length);
                    return ListView.builder(
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return ExpansionTile(
                            leading: Icon(Icons.food_bank_outlined),
                            title: Text(
                              index == 0 ? 'Fruits' : 'Vegetables',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            children: index == 0
                                ? foods
                                    .where((food) =>
                                        food.category!.compareTo('fruit') == 0)
                                    .toList()
                                    .map((food) => ListTile(
                                          title: Text(food.name!),
                                        ))
                                    .toList()
                                : foods
                                    .where((food) =>
                                        food.category!.compareTo('vegetable') ==
                                        0)
                                    .toList()
                                    .map((food) => ListTile(
                                          title: Text(food.name!),
                                        ))
                                    .toList(),
                          );
                        });
                  }
                  print(snapshot.error);
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          }
          return const Center(
            child: Text('Internet Not Connected...'),
          );
        },
      ),
    );
  }

  Future<List<Food>> loadData() async {
    final res = await http
        .get(Uri.parse('https://devaseva-assignment.herokuapp.com/api/getAll'));
    print(res.body);
    final data = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    final fruits = data['fruits'] == null
        ? []
        : List<Map<String, dynamic>>.from(data['fruits'] as List);
    final vegetables = data['vegetables'] == null
        ? []
        : List<Map<String, dynamic>>.from(data['vegetables'] as List);
    print(fruits);
    print(vegetables);
    final foods = fruits.map((fruit) => Food.fromJson(fruit, 'fruit')).toList();
    foods.addAll(vegetables
        .map((vegetable) => Food.fromJson(vegetable, 'vegetable'))
        .toList());
    return foods;
  }
}
