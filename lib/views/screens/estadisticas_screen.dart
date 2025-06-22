import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/estadistica_model.dart';
import '../../services/estadisticas_service.dart';
import '../widgets/ayuda_dialog.dart';

class EstadisticasScreen extends StatefulWidget {
  @override
  _EstadisticasScreenState createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  bool _loading = true;
  List<DenunciaEstadistica> _denuncias = [];
  List<LocalizacionEstadistica> _localizaciones = [];
  List<TopRequisitoriado> _topRequisitoriados = [];

  String _intervaloSeleccionado = 'mes';
  final List<String> _intervalos = ['mes', '6M', 'YTD', '1Y'];

  final letras = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    setState(() => _loading = true);
    try {
      final denuncias = await EstadisticasService.getDenunciasPorPeriodo(_intervaloSeleccionado);
      final localizaciones = await EstadisticasService.getEstadisticasLocalizacion('ciudad');
      final top = await EstadisticasService.getTopRequisitoriados();

      setState(() {
        _denuncias = denuncias;
        _localizaciones = localizaciones;
        _topRequisitoriados = top;
        _loading = false;
      });
    } catch (e) {
      print("Error al cargar estadísticas: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Image.asset('assets/tabler_spy.png', width: 30),
                    const SizedBox(width: 10),
                    const Text("Estadísticas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.black),
                      onPressed: () {
                        AyudaDialog.mostrar(
                          context: context,
                          titulo: 'Ayuda - Estadísticas',
mensaje: '''
📈 Tendencia de Denuncias:  
Observa cómo han evolucionado las denuncias a lo largo del tiempo. Puedes cambiar entre distintos periodos:

- Mes: últimos 30 días  
- 6M: últimos 6 meses  
- YTD (Year To Date): desde enero del año en curso hasta hoy  
- 1Y: últimos 12 meses  

El gráfico muestra tres puntos clave (inicio, mitad y final) para facilitar la interpretación.


📍 Denuncias por Departamento:
Ranking de departamentos con mayor cantidad de denuncias reportadas por los usuarios.

🥇 Requisitoriados más Denunciados:
Lista de las personas con más denuncias. Clasificados de la letra A (más reportado) a la E (menos).

ℹ️ Nota:
Puedes cambiar el intervalo de tiempo para analizar diferentes tendencias en las estadísticas.
''',

                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('📈 Tendencia de Denuncias', style: Theme.of(context).textTheme.titleMedium),
                                DropdownButton<String>(
                                  value: _intervaloSeleccionado,
                                  items: _intervalos.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _intervaloSeleccionado = value!;
                                    });
                                    cargarEstadisticas();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildLineaDenuncias(),
                            const SizedBox(height: 24),
                            Text('📊 Denuncias por Departamento', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            _buildBarrasLocalizacion(),
                            const SizedBox(height: 24),
                            Text('🥇 Top Requisitoriados', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            _buildPieChartTop(),
                            const SizedBox(height: 16),
                            _buildLeyendaTop(),
                          ],
                        ),
                ),
              ),
              if (!isKeyboardOpen)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Text(
                      'Resumen gráfico de denuncias y requisitoriados.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineaDenuncias() {
  if (_denuncias.isEmpty) return const SizedBox();

  final datos = [..._denuncias];

  String formatearFecha(String fecha) {
    final dt = DateTime.tryParse(fecha);
    if (dt == null) return '';
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    switch (_intervaloSeleccionado) {
      case 'mes':
      case '6M':
        return '${dt.day} ${meses[dt.month - 1]}';
      case 'YTD':
      case '1Y':
        return '${meses[dt.month - 1]} ${dt.year}';
      default:
        return '${dt.month}/${dt.year}';
    }
  }

  final puntos = datos
      .asMap()
      .entries
      .map((e) => FlSpot(e.key.toDouble(), e.value.cantidad.toDouble()))
      .toList();

  final maxY = datos.map((d) => d.cantidad.toDouble()).reduce((a, b) => a > b ? a : b) * 1.1;

  // Eje X: solo 3 etiquetas únicas (inicio, medio, final)
  final total = datos.length;
  final posiciones = <int>[0, total ~/ 2, total - 1];
  final etiquetasUnicas = <String>{};
  final Map<int, String> posicionesConEtiqueta = {};

  for (int idx in posiciones) {
    final texto = formatearFecha(datos[idx].periodo);
    if (!etiquetasUnicas.contains(texto)) {
      posicionesConEtiqueta[idx] = texto;
      etiquetasUnicas.add(texto);
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final idx = value.toInt();
    if (posicionesConEtiqueta.containsKey(idx)) {
      return SideTitleWidget(
        meta: meta,
        child: Text(posicionesConEtiqueta[idx]!, style: const TextStyle(fontSize: 10)),
      );
    }
    return const SizedBox.shrink();
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(value.round().toString(), style: const TextStyle(fontSize: 10)),
    );
  }

  return SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        minX: 0,
        maxX: (datos.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: puntos,
            isCurved: true,
            dotData: FlDotData(show: true),
            color: Colors.green,
            barWidth: 3,
          ),
        ],
      ),
    ),
  );
}





  Widget _buildBarrasLocalizacion() {
    List<LocalizacionEstadistica> top5 = [..._localizaciones];
    top5.sort((a, b) => b.cantidad.compareTo(a.cantidad));
    top5 = top5.take(5).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: top5
              .asMap()
              .entries
              .map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.cantidad.toDouble(),
                        color: Colors.blue,
                        width: 16,
                      )
                    ],
                  ))
              .toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, _) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= top5.length) return const SizedBox();
                  return Text(top5[idx].nombre, style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _buildPieChartTop() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _topRequisitoriados.asMap().entries.map((e) {
            final total = _topRequisitoriados.fold(0, (sum, item) => sum + item.cantidad);
            final value = e.value.cantidad.toDouble();
            final letra = letras[e.key];
            return PieChartSectionData(
              title: letra,
              value: value,
              color: Colors.primaries[e.key % Colors.primaries.length],
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildLeyendaTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _topRequisitoriados.asMap().entries.map((e) {
        final letra = letras[e.key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text('🔹 $letra: ${e.value.nombre} (${e.value.cantidad})'),
        );
      }).toList(),
    );
  }
}
