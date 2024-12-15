;                                                         -*-Scheme-*-
;;;
;;; Add the default component libraries
;;;

(define geda-awesome-sym-path (build-path geda-data-path "sym-awesome"))
(for-each
 (lambda (dir)
   (if (list? dir)
       (component-library (build-path geda-awesome-sym-path (car dir)) (cadr dir))
       (component-library (build-path geda-awesome-sym-path dir)))
   )
 (reverse '(
    ("connectors" "Connectors (a)")
    ("components" "Component Symbols (a)")
    ("power" "Power (a)")
    ("generic" "Generic Symbols (a)")
    ("ghdl" "GHDL circuits (a)")
    ("hydraulics" "Hydraulic circuits (a)")
    ("installation" "Installation (a)")
    ("piping" "Process and Instrumentation Diagrams (a)")
    ("sheets" "Sheets (a)")
    ("structural" "Structural steel schematics (a)")
    ("vhdl" "VHDL (a)")
    ("diodes" "Diodes (a)")
    ("audio" "Audio devices (a)")
    )))
