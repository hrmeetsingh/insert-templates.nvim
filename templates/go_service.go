package {{_file_name_}}

// {{_camel_file_}} provides a service stub.
//
// Author: {{_author_}}
// Date:   {{_date_}}

type {{_camel_file_}} struct{}

func New{{_camel_file_}}() *{{_camel_file_}} {
	return &{{_camel_file_}}{}
}

func (s *{{_camel_file_}}) Run() error {
	{{_cursor_}}
	return nil
}
