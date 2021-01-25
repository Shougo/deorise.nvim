# ============================================================================
# FILE: rplugin.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

import typing

from pynvim import Nvim


class Rplugin:

    def __init__(self, vim: Nvim) -> None:
        self._vim = vim

    def init_channel(self) -> None:
        self._vim.vars['deorise#_channel_id'] = self._vim.channel_id

    def start(self, args: typing.List[typing.Any]) -> None:
        pass

    def do_action(self, args: typing.List[typing.Any]) -> None:
        pass
