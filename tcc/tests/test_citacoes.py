"""Regressão do CSL local: python -m unittest discover -s tcc/tests -v.

Requer typst e pdftotext no PATH. Usa o banco real, sem alterar metadados ou
gerar PDFs no repositório. As obras adicionais são citadas apenas no teste.
"""

from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


TCC = Path(__file__).resolve().parents[1]


class CitacoesTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="tcc-citacoes-")
        cls.addClassCleanup(cls.temp.cleanup)
        directory = Path(cls.temp.name)
        shutil.copy2(TCC / "referencias.yml", directory / "referencias.yml")
        shutil.copy2(TCC / "template/abnt-datas.csl", directory / "abnt-datas.csl")
        source = directory / "citacoes.typ"
        source.write_text(
            """#set text(lang: "pt", region: "BR")
AGRUPADAS: @javatc-ces @javatc-les.

CAPACITANCIA: @javatc-ces.

INDUTANCIA: @javatc-les.

PROSA: #cite(<javatc-les>, form: "prose").

DATADA: @javatc2020.

SEM_DATA_UNICA: @wilson-design.

MESMO_ANO: @freau2000-nst-static-rotary @freau2000-nst-input-voltage.

#bibliography("referencias.yml", style: "abnt-datas.csl",
  title: [REFERENCIAS], full: false)
""",
            encoding="utf-8",
        )
        pdf = directory / "citacoes.pdf"
        subprocess.run(["typst", "compile", str(source), str(pdf)], check=True)
        text = subprocess.check_output(
            ["pdftotext", "-layout", str(pdf), "-"], text=True
        )
        cls.text = " ".join(text.split())
        cls.body, cls.bibliography = cls.text.split("REFERENCIAS", 1)

    def test_citacoes_individuais_identificam_as_duas_fontes(self):
        self.assertIn("CAPACITANCIA: (Anderson, [S.d.]a).", self.body)
        self.assertIn("INDUTANCIA: (Anderson, [S.d.]b).", self.body)
        self.assertIn("PROSA: Anderson ([S.d.]b).", self.body)

    def test_agrupamento_nao_produz_citacao_vazia(self):
        grouped = self.body.split("AGRUPADAS: ", 1)[1].split(" CAPACITANCIA:", 1)[0]
        self.assertIn("[S.d.]a", grouped)
        self.assertRegex(grouped, r"\bb\b")
        self.assertNotRegex(grouped, r";\s*\)")

    def test_bibliografia_corresponde_aos_identificadores_e_urls(self):
        for title, suffix, url in [
            ("capacitance (Ces)", "a", "out12.html"),
            ("inductance (Les)", "b", "out9.html"),
        ]:
            self.assertRegex(
                self.bibliography,
                rf"{re.escape(title)}\. \[S\.d\.\]{suffix}\. "
                rf"Disponível em: <https://classictesla\.com/java/javatc/"
                rf"{re.escape(url)}>\. Acesso em: 8 out\. 2026\.",
            )
        self.assertLess(
            self.bibliography.index("capacitance (Ces)"),
            self.bibliography.index("inductance (Les)"),
        )
        self.assertNotRegex(self.bibliography, r"2026[a-z]")

    def test_datas_conhecidas_e_sufixos_de_mesmo_ano(self):
        self.assertIn("DATADA: (Anderson, 2020).", self.body)
        self.assertIn("JavaTC. 2020.", self.bibliography)
        for suffix in "ab":
            self.assertIn(f"2000{suffix}", self.body)
            self.assertIn(f"2000{suffix}", self.bibliography)

    def test_obra_sem_data_unica_nao_recebe_sufixo(self):
        self.assertIn("SEM_DATA_UNICA: (Wilson, [S.d.]).", self.body)
        self.assertIn("Tesla Coil Design. [S.d.].", self.bibliography)
        self.assertNotRegex(self.bibliography, r"Tesla Coil Design\. \[S\.d\.\][a-z]")


if __name__ == "__main__":
    unittest.main()
