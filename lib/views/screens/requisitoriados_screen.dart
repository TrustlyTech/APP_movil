import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/requisitoriado.dart';
import '../../services/requisitoriado_service.dart';

class RequisitoriadosScreen extends StatefulWidget {
  @override
  _RequisitoriadosScreenState createState() => _RequisitoriadosScreenState();
}

class _RequisitoriadosScreenState extends State<RequisitoriadosScreen> {
  final service = RequisitoriadoService();
  PageController _pageController = PageController();
  int currentPage = 0;
  int totalPages = 10;
  Map<String, List<Requisitoriado>> cache = {};

  bool loading = true;
  String searchText = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  Future<void> _loadPage(int pageIndex) async {
    setState(() => loading = true);
    try {
      final key = "$pageIndex-$searchText";
      if (!cache.containsKey(key)) {
        final data = await service.getRequisitoriados(
          page: pageIndex + 1,
          nombre: searchText,
        );
        cache[key] = data['lista'];
        totalPages = data['total_paginas'] ?? totalPages;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildDotIndicator() {
    int visibleDots = 5;
    int start = 0;

    if (totalPages > visibleDots) {
      if (currentPage <= 2) {
        start = 0;
      } else if (currentPage >= totalPages - 3) {
        start = totalPages - visibleDots;
      } else {
        start = currentPage - 2;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages < visibleDots ? totalPages : visibleDots,
        (i) {
          int index = start + i;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPage == index ? Colors.black : Colors.grey[400],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(List<Requisitoriado> requisitoriados) {
    if (requisitoriados.isEmpty) {
      return Center(child: Text('No se encontraron resultados'));
    }

    // Mostrar máximo 4 requisitoriados por página
    final maxItems = 4;
    final visibles = requisitoriados.length > maxItems
        ? requisitoriados.sublist(0, maxItems)
        : requisitoriados;

    return ListView.builder(
      itemCount: visibles.length,
      padding: EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) {
        final item = visibles[index];
        final bytes = base64Decode(
          item.imagen.contains(',') ? item.imagen.split(',').last : item.imagen,
        );
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: EdgeInsets.all(8),
          height: 100,
          decoration: BoxDecoration(
            color: Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(bytes, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nombre,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 6),
                    Text(
                      'Recompensa: ${item.recompensa}',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/tabler_spy.png', width: 30),
              SizedBox(width: 10),
              Text('Lista de Buscados', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: BackButton(),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar por nombre...',
                      filled: true,
                      fillColor: Color(0xFFE0E0E0),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.trim();
                        cache.clear();
                        currentPage = 0;
                        _pageController.jumpToPage(0);
                        _loadPage(0);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: totalPages,
                          onPageChanged: (index) {
                            setState(() => currentPage = index);
                            _loadPage(index);
                          },
                          itemBuilder: (context, index) {
                            final key = "$index-$searchText";

                            if (searchText.isNotEmpty && loading) {
                              return Center(child: Text('Buscando...'));
                            }

                            if (!cache.containsKey(key)) {
                              return Center(
                                child: loading
                                  ? CircularProgressIndicator()
                                  : Text('Sin resultados'),
                              );
                            }

                            final lista = cache[key]!;
                            return _buildPage(lista);
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDotIndicator(),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
