// Central de Chamados (Baianão): cartão no painel esquerdo da tela inicial
// que abre o sistema web de chamados dentro do app (WebView2 no Windows).
// Em outros sistemas, ou se o WebView2 não estiver instalado, abre no navegador.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';

/// Endereço do sistema de chamados. Deixe vazio para esconder o cartão.
const String kTicketCenterUrl = 'https://chamados.exemplo.com.br';

class TicketCenterCard extends StatelessWidget {
  const TicketCenterCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyTheme.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.support_agent, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Central de Chamados',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Precisa de ajuda do TI? Abra ou acompanhe seus chamados.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE30613),
                foregroundColor: Colors.white,
              ),
              onPressed: () => openTicketCenter(context),
              child: const Text('Abrir chamado'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openTicketCenter(BuildContext context) async {
  if (Platform.isWindows &&
      await WebviewController.getWebViewVersion() != null) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => const _TicketCenterDialog(),
    );
    return;
  }
  await launchUrl(Uri.parse(kTicketCenterUrl),
      mode: LaunchMode.externalApplication);
}

class _TicketCenterDialog extends StatefulWidget {
  const _TicketCenterDialog();

  @override
  State<_TicketCenterDialog> createState() => _TicketCenterDialogState();
}

class _TicketCenterDialogState extends State<_TicketCenterDialog> {
  final _controller = WebviewController();
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _controller.initialize();
      // Links que abririam nova janela abrem na mesma janela.
      await _controller
          .setPopupWindowPolicy(WebviewPopupWindowPolicy.sameWindow);
      await _controller.loadUrl(kTicketCenterUrl);
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Container(
              color: MyTheme.accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Central de Chamados',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    tooltip: 'Voltar',
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _ready ? () => _controller.goBack() : null,
                  ),
                  IconButton(
                    tooltip: 'Recarregar',
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _ready ? () => _controller.reload() : null,
                  ),
                  IconButton(
                    tooltip: 'Abrir no navegador',
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    onPressed: () => launchUrl(Uri.parse(kTicketCenterUrl),
                        mode: LaunchMode.externalApplication),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _error != null
                  ? Center(
                      child: Text(
                          'Não foi possível abrir a central de chamados.\n$_error',
                          textAlign: TextAlign.center))
                  : _ready
                      ? Webview(_controller)
                      : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
