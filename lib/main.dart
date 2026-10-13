import 'package:flutter/material.dart';

void main() {
  runApp(const MiAppCasa());
}

class MiAppCasa extends StatelessWidget {
  const MiAppCasa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Casa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PantallaNavegacionPrincipal(),
    );
  }
}

// MODELOS DE DATOS
class Alimento {
  final String nombre;
  final double cantidadPaquete; // ej. 500, 1, 250
  final String unidad; // 'gr', 'kg', 'ml', 'L', 'un'

  Alimento({
    required this.nombre,
    required this.cantidadPaquete,
    required this.unidad,
  });

  String get descripcionCompleta => '$nombre ($cantidadPaquete $unidad)';
}

class ProductoCompra {
  final String nombre;
  final String lugar;
  final int paquetesComprados;
  final double cantidadPorPaquete;
  final String unidad;
  final double precioUnitarioPaquete;

  ProductoCompra({
    required this.nombre,
    required this.lugar,
    required this.paquetesComprados,
    required this.cantidadPorPaquete,
    required this.unidad,
    required this.precioUnitarioPaquete,
  });

  double get subtotal => paquetesComprados * precioUnitarioPaquete;
  double get cantidadTotalProd => paquetesComprados * cantidadPorPaquete;
}

// NAVEGACIÓN PRINCIPAL
class PantallaNavegacionPrincipal extends StatefulWidget {
  const PantallaNavegacionPrincipal({super.key});

  @override
  State<PantallaNavegacionPrincipal> createState() => _PantallaNavegacionPrincipalState();
}

class _PantallaNavegacionPrincipalState extends State<PantallaNavegacionPrincipal> {
  int _indicePestana = 0;

  // Listas de datos guardados
  final List<String> _tiendasGuardadas = ['Supermercado Coto', 'Verdulería del Barrio', 'Carrefour'];
  final List<Alimento> _alimentosGuardados = [
    Alimento(nombre: 'Fideos Moñito', cantidadPaquete: 500, unidad: 'gr'),
    Alimento(nombre: 'Leche Entera', cantidadPaquete: 1, unidad: 'L'),
    Alimento(nombre: 'Huevos Maple', cantidadPaquete: 30, unidad: 'un'),
    Alimento(nombre: 'Arroz Integral', cantidadPaquete: 1, unidad: 'kg'),
  ];

  @override
  Widget build(BuildContext context) {
    final paginas = [
      RegistroComprasPantalla(
        tiendas: _tiendasGuardadas,
        alimentos: _alimentosGuardados,
      ),
      GestionCatalogosPantalla(
        tiendas: _tiendasGuardadas,
        alimentos: _alimentosGuardados,
        onActualizar: () => setState(() {}),
      ),
    ];

    return Scaffold(
      body: paginas[_indicePestana],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indicePestana,
        onTap: (index) => setState(() => _indicePestana = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Registrar Compra'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Tiendas y Alimentos'),
        ],
      ),
    );
  }
}

// PESTAÑA 1: REGISTRO DE COMPRAS
class RegistroComprasPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<Alimento> alimentos;

  const RegistroComprasPantalla({
    super.key,
    required this.tiendas,
    required this.alimentos,
  });

  @override
  State<RegistroComprasPantalla> createState() => _RegistroComprasPantallaState();
}

class _RegistroComprasPantallaState extends State<RegistroComprasPantalla> {
  String? _tiendaSeleccionada;
  Alimento? _alimentoSeleccionado;

  final _nombreManualController = TextEditingController();
  final _paquetesController = TextEditingController(text: '1');
  final _tamanoPaqueteController = TextEditingController();
  final _precioPaqueteController = TextEditingController();
  final _descuentoController = TextEditingController();

  String _unidadSeleccionada = 'gr';
  final List<String> _unidadesDisponibles = ['gr', 'kg', 'ml', 'L', 'un'];
  final List<ProductoCompra> _productosTicket = [];
  bool _descuentoEnPorcentaje = true;

  void _alSeleccionarAlimento(Alimento? alimento) {
    if (alimento != null) {
      setState(() {
        _alimentoSeleccionado = alimento;
        _nombreManualController.text = alimento.nombre;
        _tamanoPaqueteController.text = alimento.cantidadPaquete.toString();
        _unidadSeleccionada = alimento.unidad;
      });
    }
  }

  void _agregarProducto() {
    final tienda = _tiendaSeleccionada;
    final nombre = _nombreManualController.text.trim();
    final paquetes = int.tryParse(_paquetesController.text.trim()) ?? 0;
    final tamanoPaquete = double.tryParse(_tamanoPaqueteController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final precio = double.tryParse(_precioPaqueteController.text.trim().replaceAll(',', '.')) ?? 0.0;

    if (tienda == null || tienda.isEmpty) {
      _mostrarMensaje('Por favor selecciona o agrega una tienda.');
      return;
    }
    if (nombre.isEmpty || paquetes <= 0 || tamanoPaquete <= 0 || precio <= 0) {
      _mostrarMensaje('Completa el nombre, cantidad de paquetes, tamaño y precio.');
      return;
    }

    setState(() {
      _productosTicket.add(ProductoCompra(
        nombre: nombre,
        lugar: tienda,
        paquetesComprados: paquetes,
        cantidadPorPaquete: tamanoPaquete,
        unidad: _unidadSeleccionada,
        precioUnitarioPaquete: precio,
      ));

      _alimentoSeleccionado = null;
      _nombreManualController.clear();
      _tamanoPaqueteController.clear();
      _precioPaqueteController.clear();
      _paquetesController.text = '1';
    });
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  double get _subtotalGeneral => _productosTicket.fold(0, (sum, item) => sum + item.subtotal);

  double get _valorDescuento => double.tryParse(_descuentoController.text.trim().replaceAll(',', '.')) ?? 0.0;

  double get _montoDescuentoTotal {
    if (_subtotalGeneral == 0) return 0.0;
    double desc = _descuentoEnPorcentaje ? _subtotalGeneral * (_valorDescuento / 100) : _valorDescuento;
    return desc > _subtotalGeneral ? _subtotalGeneral : desc;
  }

  double get _totalConDescuento => _subtotalGeneral - _montoDescuentoTotal;

  double _calcularPrecioFinalPorPaquete(ProductoCompra prod) {
    if (_subtotalGeneral == 0) return prod.precioUnitarioPaquete;
    final proporcion = prod.subtotal / _subtotalGeneral;
    final descuentoProd = _montoDescuentoTotal * proporcion;
    return (prod.subtotal - descuentoProd) / prod.paquetesComprados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Compras'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seleccionar Tienda
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<String>(
                  value: _tiendaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Tienda / Comercio',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                  items: widget.tiendas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _tiendaSeleccionada = val),
                  hint: const Text('Elije una tienda guardada'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Formulario Agregar Producto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Añadir Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),

                    // Selector de plantilla guardada
                    if (widget.alimentos.isNotEmpty) ...[
                      DropdownButtonFormField<Alimento>(
                        value: _alimentoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Elegir del Catálogo Guardado',
                          prefixIcon: Icon(Icons.fastfood),
                          border: OutlineInputBorder(),
                        ),
                        items: widget.alimentos
                            .map((a) => DropdownMenuItem(value: a, child: Text(a.descripcionCompleta)))
                            .toList(),
                        onChanged: _alSeleccionarAlimento,
                        hint: const Text('Cargar alimento rápido...'),
                      ),
                      const SizedBox(height: 10),
                    ],

                    TextField(
                      controller: _nombreManualController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _tamanoPaqueteController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Contenido c/u',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _unidadSeleccionada,
                            decoration: const InputDecoration(
                              labelText: 'Unid.',
                              border: OutlineInputBorder(),
                            ),
                            items: _unidadesDisponibles
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _unidadSeleccionada = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _paquetesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cant. Paquetes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _precioPaqueteController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Precio x Paq. (\$)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _agregarProducto,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Agregar al Ticket'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Lista de productos del ticket
            const Text('Productos en el Ticket:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            _productosTicket.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('El ticket está vacío.')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _productosTicket.length,
                    itemBuilder: (context, index) {
                      final prod = _productosTicket[index];
                      final precioFinalPaquete = _calcularPrecioFinalPorPaquete(prod);

                      return Card(
                        child: ListTile(
                          title: Text('${prod.nombre} (x${prod.paquetesComprados} de ${prod.cantidadPorPaquete}${prod.unidad})'),
                          subtitle: Text(
                            'Original: \$${prod.precioUnitarioPaquete.toStringAsFixed(2)} c/u\n'
                            'Con desc.: \$${precioFinalPaquete.toStringAsFixed(2)} c/u (Total: ${prod.cantidadTotalProd} ${prod.unidad})',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${(precioFinalPaquete * prod.paquetesComprados).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => _productosTicket.removeAt(index)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 12),

            // Descuento y Totales
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _descuentoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: _descuentoEnPorcentaje ? 'Descuento (%)' : 'Descuento (\$)',
                              prefixIcon: const Icon(Icons.discount),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: true, label: Text('%')),
                              ButtonSegment(value: false, label: Text('\$')),
                            ],
                            selected: {_descuentoEnPorcentaje},
                            onSelectionChanged: (val) => setState(() => _descuentoEnPorcentaje = val.first),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('\$${_subtotalGeneral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_descuentoEnPorcentaje ? 'Descuento (${_valorDescuento.toStringAsFixed(1)}%):' : 'Descuento Fijo:'),
                        Text('-\$${_montoDescuentoTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL FINAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          '\$${_totalConDescuento.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PESTAÑA 2: GESTIÓN DE TIENDAS Y ALIMENTOS
class GestionCatalogosPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<Alimento> alimentos;
  final VoidCallback onActualizar;

  const GestionCatalogosPantalla({
    super.key,
    required this.tiendas,
    required this.alimentos,
    required this.onActualizar,
  });

  @override
  State<GestionCatalogosPantalla> createState() => _GestionCatalogosPantallaState();
}

class _GestionCatalogosPantallaState extends State<GestionCatalogosPantalla> {
  final _tiendaNombreController = TextEditingController();
  final _alimentoNombreController = TextEditingController();
  final _alimentoCantidadController = TextEditingController();
  String _unidadSeleccionada = 'gr';
  final List<String> _unidades = ['gr', 'kg', 'ml', 'L', 'un'];

  void _agregarTienda() {
    final nombre = _tiendaNombreController.text.trim();
    if (nombre.isNotEmpty && !widget.tiendas.contains(nombre)) {
      setState(() {
        widget.tiendas.add(nombre);
        _tiendaNombreController.clear();
      });
      widget.onActualizar();
    }
  }

  void _agregarAlimento() {
    final nombre = _alimentoNombreController.text.trim();
    final cantidad = double.tryParse(_alimentoCantidadController.text.trim().replaceAll(',', '.')) ?? 0.0;

    if (nombre.isNotEmpty && cantidad > 0) {
      setState(() {
        widget.alimentos.add(Alimento(
          nombre: nombre,
          cantidadPaquete: cantidad,
          unidad: _unidadSeleccionada,
        ));
        _alimentoNombreController.clear();
        _alimentoCantidadController.clear();
      });
      widget.onActualizar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Catálogos'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Tiendas'),
              Tab(icon: Icon(Icons.fastfood), text: 'Alimentos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña Tiendas
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tiendaNombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nueva Tienda (ej. Verdulería Juan)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _agregarTienda,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.tiendas.length,
                      itemBuilder: (context, index) {
                        final t = widget.tiendas[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(t),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => widget.tiendas.removeAt(index));
                                widget.onActualizar();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Pestaña Alimentos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Guardar Nuevo Alimento', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _alimentoNombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre (ej. Fideos Lucchetti)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _alimentoCantidadController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Tamaño Paquete',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  value: _unidadSeleccionada,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                  items: _unidades.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _unidadSeleccionada = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _agregarAlimento,
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar Alimento en Catálogo'),
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.alimentos.length,
                      itemBuilder: (context, index) {
                        final a = widget.alimentos[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.fastfood),
                            title: Text(a.nombre),
                            subtitle: Text('Tamaño base: ${a.cantidadPaquete} ${a.unidad}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => widget.alimentos.removeAt(index));
                                widget.onActualizar();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
