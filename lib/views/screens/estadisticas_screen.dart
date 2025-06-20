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

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    try {
      final denuncias = await EstadisticasService.getDenunciasPorPeriodo('mes');
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
                    const Text(
                      "Estadísticas",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.black),
                      onPressed: () {
                        AyudaDialog.mostrar(
                          context: context,
                          titulo: 'Ayuda - Estadísticas',
                          mensaje: '''
En esta vista puedes ver un resumen gráfico de la actividad en Identity:

📈 Denuncias por Mes:
Muestra la evolución de la cantidad de denuncias registradas por mes. Útil para detectar patrones, picos o anomalías en la actividad.

📊 Denuncias por Departamento:
Indica en qué regiones del país se han detectado más personas incluidas en el programa de recompensas. Útil para reconocer zonas críticas.

🥇 Top Requisitoriados:
Muestra a las 5 personas más denunciadas por los usuarios a través de Identity. Esta sección destaca a los requisitoriados con mayor número de denuncias.

Este apartado nos sirve para evaluar el impacto de la app y entender el comportamiento de las Denuncias.
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
                            Text('📈 Denuncias por Mes', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: (_denuncias.length - 1).toDouble(),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 22,
                                        getTitlesWidget: (value, _) {
                                          int idx = value.toInt();
                                          if (idx < 0 || idx >= _denuncias.length) return const SizedBox();
                                          return Text(_denuncias[idx].periodo.split(' ')[0], style: const TextStyle(fontSize: 10));
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                                    ),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(show: true, drawVerticalLine: false),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _denuncias
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(e.key.toDouble(), e.value.cantidad.toDouble()))
                                          .toList(),
                                      isCurved: true,
                                      dotData: FlDotData(show: true),
                                      color: Colors.green,
                                      barWidth: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text('📊 Denuncias por Departamento', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  barGroups: _localizaciones
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
                                          if (idx < 0 || idx >= _localizaciones.length) return const SizedBox();
                                          return Text(_localizaciones[idx].nombre, style: const TextStyle(fontSize: 10));
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
                            ),
                            const SizedBox(height: 24),
                            Text('🥇 Top Requisitoriados', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: _topRequisitoriados
                                      .asMap()
                                      .entries
                                      .map((e) {
                                        final total = _topRequisitoriados.fold(0, (sum, item) => sum + item.cantidad);
                                        final value = e.value.cantidad.toDouble();
                                        final percent = (value / total) * 100;
                                        return PieChartSectionData(
                                          title: '${e.value.nombre}\n${percent.toStringAsFixed(1)}%',
                                          value: value,
                                          color: Colors.primaries[e.key % Colors.primaries.length],
                                          radius: 60,
                                          titleStyle: const TextStyle(color: Colors.white, fontSize: 10),
                                        );
                                      })
                                      .toList(),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
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
}
