import MalTypes

proc pr_str*(malData: MalData, print_readably: bool = true): string =
    malData.toString(print_readably)
