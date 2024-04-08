#!/usr/bin/python3

from fpdf import FPDF
import datetime






class PDF(FPDF):
	def header(self):
		self.set_font('helvetica', 'B', 10)
		self.cell(80)
		self.cell(30,10,'Aktios Security Services S.L.',1,0,'C')




pdf = PDF()


pdf.add_page()
pdf.set_font('helvetica', '', 24)

pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)

pdf.cell(195,10,'"Empresa en cuestion"', align = 'C')

pdf.ln(5)
pdf.ln(5)

pdf.set_font('helvetica', '', 18)
pdf.cell(195,10,'Reporte de exposicion en fuentes abiertas', align = 'C')

pdf.ln(150)
pdf.ln(5)
pdf.ln(5)

date = datetime.datetime.now()
actualdate = datetime.datetime.strftime(date, '%d/%m/%Y')

pdf.set_font('helvetica', '', 11)
pdf.cell(195,10,text= str(actualdate), align = 'R')
pdf.ln(5)
pdf.cell(195,10,'Aktios Security Services S.L.', align = 'R')


pdf.ln(5)
pdf.ln(5)
pdf.ln(5)


pdf.set_margin(20)

pdf.set_font('helvetica', '', 20)
pdf.cell(195,10,'Scope',align = 'L')

pdf.ln(5)
pdf.ln(5)

pdf.set_font('helvetica', '', 11)
pdf.cell(195,10,'<IPs, dominios e emails indicados por el cliente para investigar>', align = 'L')


pdf.ln(5)
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)



pdf.set_font('helvetica', '', 20)
pdf.cell(195,10,'Valoracion global',align = 'L')

pdf.ln(5)
pdf.ln(5)
pdf.ln(5)

pdf.set_font('helvetica', '', 11)

archivo = open("texto1.txt", "r")
texto1 = archivo.read()
archivo.close()

pdf.multi_cell(195, 7,text= texto1)

pdf.ln(5)
pdf.ln(5)

pdf.set_font('helvetica', '', 20)
pdf.cell(195,10,'Descubrimientos',align = 'L')


pdf.ln(5)
pdf.ln(5)
pdf.ln(5)


pdf.set_font('helvetica', '', 11)
pdf.cell(195,10,'IPs, dominios y subdominios relacionados con la empresa: ',align = 'L')

pdf.ln(5)
pdf.ln(5)


datos_tabla = (
("(Sub)Dominio","IP","Informacion donde apunta"),
("ejemplo.ej","ej.em.plo", "ejemplo.com"),
("ejemplo.ej","ej.em.plo", "ejemplo.com"),
("ejemplo.ej","ej.em.plo", "ejemplo.com"),
)

with pdf.table() as table:
	for data_row in datos_tabla:
		row = table.row()
		for datum in data_row:
			row.cell(datum)

pdf.ln(5)
pdf.ln(5)
pdf.ln(5)



pdf.set_font('helvetica', '', 20)
pdf.cell(195,10,'Informacion personal de la empresa',align = 'L')


pdf.set_font('helvetica', '', 11)

archivo2 = open("texto2.txt", "r")
texto2 = archivo2.read()
archivo2.close()


pdf.multi_cell(195, 7,text= texto2)

pdf.ln(5)
pdf.ln(5)

pdf.cell(195,10,'Correos:',align = 'L')
pdf.ln(5)
pdf.ln(5)
pdf.cell(195,10,'Telefonos: ',align = 'L')
pdf.ln(5)
pdf.ln(5)
pdf.cell(195,10,'Direcciones: ',align = 'L')
pdf.ln(5)
pdf.ln(5)
pdf.ln(5)


pdf.set_font('helvetica', '', 20)
pdf.cell(195,10,'Tecnologias',align = 'L')

pdf.set_font('helvetica', '', 11)

pdf.ln(5)
pdf.ln(5)
pdf.ln(5)


datos_tabla = (
("IP","Puerto","Tecnologia"),
("ej.em.plo","X", "EJEMPLO"),
("ej.em.plo","X", "EJEMPLO"),
("ej.em.plo","X", "EJEMPLO"),
)

with pdf.table() as table:
	for data_row in datos_tabla:
		row = table.row()
		for datum in data_row:
			row.cell(datum)


pdf.ln(5)
pdf.ln(5)
pdf.ln(5)

pdf.set_font('helvetica', '', 20)
pdf.cell(195,10,'Vulnerabilidades destacads',align = 'L')




pdf.output('pdf_2.pdf')


