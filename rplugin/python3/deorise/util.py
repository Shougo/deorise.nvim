# ============================================================================
# FILE: util.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

import typing
from pynvim import Nvim

UserContext = typing.Dict[str, typing.Any]


def error(vim: Nvim, expr: typing.Any) -> None:
    """
    Prints the error messages to Vim/Nvim's :messages buffer.
    """
    vim.call('deorise#util#print_error', expr)


def confirm(vim: Nvim, question: str) -> bool:
    """
    Confirm action
    """
    option: int = vim.call('deorise#util#confirm',
                           question, '&Yes\n&No\n&Cancel', 2)
    return option == 1
