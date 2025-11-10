.PHONY: all env install run notebook results clean

# ==================================================================
# MPPT — P&O vs MLP (dados JRC + perfis sintéticos)
# Makefile de reprodutibilidade rápida
#
# Requisitos:
#   - Python 3.10+
#   - Este Makefile, requirements.txt e notebooks/mppt.ipynb
#
# Uso típico:
#   make env install         # cria venv e instala dependências
#   make run                 # executa o notebook com papermill
#   make results             # garante pastas de resultados
#   make clean               # limpa artefatos
#
# Parâmetros que você pode ajustar via linha de comando:
#   make run JRC=data/JRC/porto.csv SYN=data/synthetic/steps.csv
# ==================================================================

# ---- Variáveis ----
VENV ?= .venv
PY   := $(VENV)/bin/python
PIP  := $(VENV)/bin/pip
PM   := $(VENV)/bin/papermill

# Caminhos padrão (ajuste se necessário)
NB_IN    ?= notebooks/mppt.ipynb
NB_OUT   ?= results/mppt_exec.ipynb
JRC      ?= data/JRC/porto.csv
SYN      ?= data/synthetic/steps.csv

# Pastas de resultados
RESULTS_DIRS = results results/figures results/tables results/logs

all: env install results run

# Cria o ambiente virtual
env:
	@[ -d "$(VENV)" ] || python -m venv $(VENV)
	@echo "✅ Ambiente virtual pronto em $(VENV)"

# Instala dependências
install: env
	@$(PIP) install -U pip wheel
	@$(PIP) install -r requirements.txt
	@echo "✅ Dependências instaladas"

# Garante a estrutura de pastas de resultados
results:
	@mkdir -p $(RESULTS_DIRS)
	@echo "✅ Pastas de resultados criadas: $(RESULTS_DIRS)"

# Executa o notebook com papermill (permite parametrização)
# Parâmetros esperados no notebook (se existirem):
#   - JRC_CSV: caminho para CSV do JRC
#   - SYN_CSV: caminho para CSV sintético
run: results
	@echo "▶️ Executando $(NB_IN) -> $(NB_OUT)"
	@$(PM) "$(NB_IN)" "$(NB_OUT)" \
		-p JRC_CSV "$(JRC)" \
		-p SYN_CSV "$(SYN)" \
		--log-output \
		--cwd "."
	@echo "✅ Execução concluída: $(NB_OUT)"
	@echo "ℹ️  Ajuste as chaves -p JRC_CSV e -p SYN_CSV conforme os nomes de parâmetros do seu notebook."

# Abre o notebook executado (se desejar)
notebook:
	@$(PY) - <<'PYCODE'\
import webbrowser, os\
p=os.path.abspath('$(NB_OUT)')\
print('Abrindo:', p)\
webbrowser.open('file://' + p)\
PYCODE

# Limpa artefatos comuns
clean:
	@rm -rf __pycache__ .pytest_cache .mypy_cache .ruff_cache .ipynb_checkpoints \
		results/*.log results/*.tmp results/*.txt \
		results/figures/* results/tables/* \
		$(NB_OUT)
	@echo "🧹 Limpeza concluída"
