#!/bin/sh -e
##:
#h: Usage: ./build.sh show|...
#h:
#h: Gather symbols:
#h:
#h:   update
#h:   all|bert|cwru|salfter|backerman|stefanct|jonronen|tomahawkins|unclerus
#h:
#h: Generate readme:
#h:
#h:   images
#h:   catalogs
#h:   readme
#h:
#h: Fill the "sym/" directory with symbols from different sources.
##:
eda_lepton_symbols() {
    local cmd="$1"
    shift
    case "${cmd}" in
        show)     eda_lepton_symbols_show_variables ;;
        all)      for cmd in ${AWESOME_REPOS}; do edal_"${cmd}"; done; edal_update ;;
        update)   edal_update ;;
        images)   edal_images ;;
        catalogs) edal_catalogs ;;
        readme)   edal_readme ;;
        *)        edal_"${cmd}"; edal_update ;;
    esac
}
eda_lepton_symbols_show_variables() {
    echo "OPWD           : ${OPWD}"
    echo "AWESOME_LEPTON : ${AWESOME_LEPTON}"
    echo "AWESOME_REPOS  : ${AWESOME_REPOS}"
}
eda_lepton_symbols_calc_variables() {
    OPWD="$(pwd)"
    cd "$(dirname "$0")"
    AWESOME_LEPTON="$(pwd)"
    AWESOME_SED="$(cat ORGANIZER.sed)"
    cd "${OPWD}"
    AWESOME_REPOS="${AWESOME_REPOS:-bert cwru salfter backerman stefanct jonronen tomahawkins unclerus}"
    
}
eda_lepton_symbols_descriptions() {
    cat <<-EOF
	components    Component Symbols
	generic       Generic Symbols
	ghdl          GHDL circuits
	hydraulics    Hydraulic circuits
	installation  Installation
	piping        Process and Instrumentation Diagrams
	power         Power
	sheets        Sheets
	structural    Structural steel schematics
	vhdl          VHDL
	unsorted      Unsorted
	audio         Audio devices
	connectors    Connectors
	diodes        Diodes
	EOF
}
## -------------------------------------------------------------------
edal_images() {
    find "${AWESOME_LEPTON}/sym-awesome" -name '*.sym' | sort | while read -r sym; do
        local png="$(echo "${sym}" | sed 's|\.sym$|.png|g')"
        if test ! -f "${png}"; then
            lepton-cli export -f png -o "${png}" "${sym}" >&2
            echo "${png}"
        fi
    done
}
edal_catalogs() {
    local odir="${AWESOME_LEPTON}/catalogs" dir images oimage last i1 i2 i3 i4 num col
    rm -rf "${odir}"
    mkdir -p "${odir}"
    
    for dir in $(find "${AWESOME_LEPTON}/sym-awesome" -mindepth 1 -maxdepth 1 -type d); do
        num="1" col="$(basename "${dir}")"
        find "${dir}" -name '*.png' | sort | while read -r i1; do
            read -r i2 || true
            read -r i3 || true
            read -r i4 || true
            read -r i5 || true
            read -r i6 || true
            read -r i7 || true
            read -r i8 || true
            images="${i1}${NL}${i2}${NL}${i3}${NL}${i4}${NL}${i5}${NL}${i6}${NL}${i7}${NL}${i8}"
            oimage="$(printf '%s/%s_%05i.png' "${odir}" "${col}" "${num}")"
            num=$(( num + 1 ))
            echo "Generating ${oimage} ..."
            montage -annotate +0+10 "%t" ${images} -geometry +10+10 -tile 4x -frame 5 -background white "${oimage}"
        done
    done
    
}
edal_readme() {
    local dir name tmp1="$(mktemp)" tmp2="$(mktemp)"
    cd "${AWESOME_LEPTON}"
    for dir in $(find "./sym-awesome" -mindepth 1 -maxdepth 1 -type d); do
        name="$(basename "${dir}")"
        desc="$(test ! -f "${dir}/DESC" | head -n 1 "${dir}/DESC")"
        desc="${desc:-${name}}"
        label="$(echo "${desc}" | tr ' ' '-')"
        if true; then
            echo "- [${desc}](#${label})"
        fi >> "${tmp1}"
        if true; then
            echo ""
            echo "### ${desc}"
            echo ""
            for img in $(find "./catalogs" -name "${name}_*.png" | sort); do
                echo "![${name}](${img})"
            done
        fi >> "${tmp2}"
    done
    sed -i '/\#\# Symbol Catalog/,$d' README.md
    cat <<-EOF >> README.md
	## Symbol Catalog
	
	$(cat "${tmp1}")
	$(cat "${tmp2}")
	EOF
    rm -f "${tmp1}" "${tmp2}"
    cd "${OPWD}"
}

## -------------------------------------------------------------------
edal_bert() {
    local SDIR
    local sdirs='components generic ghdl hydraulics installation piping power sheets structural vhdl'
    local skips='drakon fishing xspice simulation ladder mechanical gnucap '
    edal_git_SDIR bert-gschem "https://github.com/bert/gschem-symbols.git"
    {
        cd "${SDIR}"
        edal_save_filenames bert
        find ${sdirs} -name '*.sym' | edal_sed bert | edal_cp
        mkdir -p "${AWESOME_LEPTON}/lic"
        cat "LICENSE" | edal_save_license bert_GPLv2
        cd "${OPWD}"
    }
}
edal_cwru() {
    local SDIR
    edal_git_SDIR cwru-gschem "https://github.com/CWRU-EE/gschem-symbols.git"
    {
        cd "${SDIR}"
        edal_save_filenames cwru
        find -name '*.sym' | edal_sed cwru components cw | edal_cp
        echo "See https://github.com/CWRU-EE/gschem-symbols" | edal_save_license cwru
        cd "${OPWD}"
    }
}
edal_salfter() {
    local SDIR
    edal_git_SDIR salfter "https://github.com/salfter/gschem-symbols.git"
    {
        cd "${SDIR}"
        edal_save_filenames salfter
        find -name '*.sym' | edal_sed salfter components sa | edal_cp
        echo "See https://github.com/salfter/gschem-symbols" | edal_save_license salfter
        cd "${OPWD}"
    }
}
edal_backerman() {
    local SDIR
    edal_git_SDIR backerman "https://github.com/backerman/gedasyms.git"
    {
        cd "${SDIR}/gschem"
        edal_save_filenames backerman
        find -name '*.sym' | edal_sed backerman components ba | edal_cp
        echo "See https://github.com/backerman/gedasyms" | edal_save_license backerman
        cd "${OPWD}"
    }
}
edal_stefanct() {
    local SDIR
    edal_git_SDIR stefanct "https://github.com/stefanct/gedasymbols.git"
    {
        cd "${SDIR}/symbols/power"
        edal_save_filenames stefanct
        cd ../AVR;    find -name '*.sym' | edal_sed stefanct components | edal_cp
        cd ../adc;    find -name '*.sym' | edal_sed stefanct components | edal_cp
        cd ../diodes; find -name '*.sym' | edal_sed stefanct diodes     | edal_cp
        cd ../dip;    find -name '*.sym' | edal_sed stefanct connectors | edal_cp
        cd ../logic;  find -name '*.sym' | edal_sed stefanct components | edal_cp
        cd ../misc;   find -name '*.sym' | edal_sed stefanct components | edal_cp
        cd ../power;  find -name '*.sym' | edal_sed stefanct power      | edal_cp
        echo "See https://github.com/stefanct/gedasymbols" | edal_save_license stefanct
        cd "${OPWD}"
    }
}
edal_jonronen() {
    local SDIR
    edal_git_SDIR jonronen "https://github.com/jonronen/geda-stuff.git"
    {
        cd "${SDIR}/symbols"
        edal_save_filenames jonronen
        find -name '*.sym' | edal_sed jonronen components jn | edal_cp
        cd ..
        cat LICENSE | edal_save_license jonronen
        cd "${OPWD}"
    }
}
edal_tomahawkins() {
    local SDIR
    edal_git_SDIR tomahawkins "https://github.com/tomahawkins/hydraulics.git"
    {
        cd "${SDIR}"
        edal_save_filenames tomahawkins
        find -name '*.sym' | eda1_sed tomahawkins hydraulics | edal_cp
        echo "See https://github.com/tomahawkins/hydraulics" | edal_save_license tomahawkins
        cd "${OPWD}"
    }
}
edal_unclerus() {
    local SDIR
    edal_git_SDIR gsymbols "https://github.com/UncleRus/gsymbols.git"
    {
        cd "${SDIR}/Audio"
        edal_save_filenames unclerus
        cd ../Audio;       find -name '*.sym' | edal_sed unclerus audio         | edal_cp
        cd ../Connectors;  find -name '*.sym' | edal_sed unclerus connectors ru | edal_cp
        cd ../Diodes;      find -name '*.sym' | edal_sed unclerus diodes     ru | edal_cp
        cd ../IC;          find -name '*.sym' | edal_sed unclerus components ru | edal_cp
        cd ../Opto;        find -name '*.sym' | edal_sed unclerus components ru | edal_cp
        cd ../Passive;     find -name '*.sym' | edal_sed unclerus components ru | edal_cp
        cd ../Rails;       find -name '*.sym' | edal_sed unclerus power      ru | edal_cp
        cd ../Switches;    find -name '*.sym' | edal_sed unclerus components ru | edal_cp
        cd ../Transistors; find -name '*.sym' | edal_sed unclerus components ru | edal_cp
        echo "See https://github.com/UncleRus/gsymbols" | edal_save_license unclerus
        cd "${OPWD}"
    }
}
## -------------------------------------------------------------------
edal_sed() {
    local sed=""
    if test -n "$3"; then
        sed="
        s|\\.sym\$|-$3.sym|
        "
    fi
    sed '
        s|\(.*\)\.sym|\1.sym \1.sym|'"
        s| \\./| ${2:-.}/|
        ${sed}
        ${AWESOME_SED}
    "
}
edal_cp() {
    local a b ign
    while read -r a b ign; do
        mkdir -p "$(dirname "${AWESOME_LEPTON}/sym-awesome/${b}")" 
        cp -v "${a}" "${AWESOME_LEPTON}/sym-awesome/${b}"
        if test -n "${EDAL_DEST}"; then
            echo "sym-awesome/${b}" >> "${EDAL_DEST}"
        fi
    done
}
edal_update() {
    local dir desc name gafrc="gafrc" scm="scm/config-awesome-symbol-library.scm"
    cd "${AWESOME_LEPTON}"
    ## Save descriptions.
    eda_lepton_symbols_descriptions | while read -r dir desc; do
        if test -d "sym-awesome/${dir}"; then
            echo "${desc}" > "sym-awesome/${dir}/DESC"
        fi
    done
    ## Fill gafrc and scm.
    echo -n > "${gafrc}"
    mkdir -p "$(dirname "${scm}")"
    cat > "${scm}" <<-EOF
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
	EOF
    find "sym-awesome" -maxdepth 1 -mindepth 1 -type d | while read -r dir; do
        echo "${dir}" | sed 's|^\(.*\)$|(component-library "\1")|' >> "gafrc"
        name="$(basename "${dir}")"
        desc="$(test ! -f "${dir}/DESC" || head -n 1 "${dir}/DESC")"
        desc="${desc:-${name}}"
        echo "    (\"${name}\" \"${desc} (a)\")" >> "${scm}"
    done
    echo "    )))" >> "${scm}"
    ##
    cd "${OPWD}"
}
edal_save_license() {
    mkdir -p "${AWESOME_LEPTON}/lic"
    cat > "${AWESOME_LEPTON}/lic/${1}_LICENSE.txt"
    git rev-parse HEAD > "${AWESOME_LEPTON}/lic/${1}_VERSION.txt"
}
edal_save_filenames() {
    EDAL_DEST="${1}"
    mkdir -p "${AWESOME_LEPTON}/lic"
    echo -n > "${AWESOME_LEPTON}/lic/${1}_FILES.txt"
}
## -------------------------------------------------------------------
edal_git_SDIR() { # name url
    local name="$1" url="$2"
    if test ! -n "${name}" && test ! -n "${url}"; then
        echo >&2 "error: Please specify a name and url."
        return 1
    fi
    local src="${TEMP:-/tmp}/${name}"
    if test ! -e "${src}/.git"; then
        git clone "${url}" "${src}" >&2
    fi
    SDIR="${src}"
}
## -------------------------------------------------------------------
eda_lepton_symbols_calc_variables
NL="
"
if test @"${SCRNAME:-$(basename "$0")}" = @"build.sh"; then
    case "${1}" in
        ''|-h|--help) sed -n 's/^ *#h: \{0,1\}//p' "$0";;
        *)            eda_lepton_symbols "$@"; exit 0;;
    esac
fi
