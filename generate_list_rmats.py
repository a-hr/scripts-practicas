import argparse
import os

from pathlib import Path


def generate_list_SE(input_dir: Path, pattern: list) -> str:
    fe = (".fastq", ".fq", ".bam")
    output = ""
    for file in input_dir.iterdir():
        if any(p in str(file) for p in pattern if file.suffix in fe):
            output += f"{file},"
    return output.removesuffix(",")


def generate_list_PE(input_dir: Path, pattern: list) -> str:
    fe = (".fastq", ".fq", ".bam")
    output = ""
    files = list(input_dir.iterdir())

    # split in strand 1 and 2
    s1 = []
    s2 = []
    [
        s1.append(f) if f.stem.endswith("_1") else s2.append(f)
        for f in files
        if f.suffix in fe
    ]

    # add to output str if match with patterns (includes ':' separator)
    for f1 in s1:
        if any(p in str(f1) for p in pattern):
            try:
                f2 = [_f2 for _f2 in s2 if f1.stem.removesuffix("_1") in str(_f2)][0]
                output += f"{f1}:{f2},"
            except IndexError:
                output += f"{f1},"
    return output.removesuffix(",")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="""
    Generate input .txt files for rMATS from an input directory and a pattern (or list of patterns) 
    """
    )

    parser.add_argument(
        "input_dir",
        type=str,
        help="folder containing the input files (.fastq/.bam)",
    )

    parser.add_argument(
        "-o",
        type=str,
        nargs="?",
        default="output.txt",
        help="name of the output .txt file",
    )

    parser.add_argument(
        "patterns",
        nargs="+",
        default=[],
        help="1 or more patterns to match (sep: space)",
    )

    parser.add_argument(
        "-PE",
        nargs="?",
        default=False,
        type=bool,
        choices=[True, False],
        help="default: False",
    )

    args = parser.parse_args()

    inp = Path(args.input_dir).resolve()
    out = Path(os.getcwd()).resolve() / args.o

    patterns = args.patterns[0].split(",") if len(args.patterns) == 1 else args.patterns
    patterns = [x for x in patterns if x]

    handler = generate_list_PE if args.PE else generate_list_SE

    with open(out, "w") as f:
        f.write(handler(inp, patterns))


if __name__ == "__main__":
    main()
