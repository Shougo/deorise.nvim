# ============================================================================
# FILE: __init__.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

import typing

from importlib.util import find_spec
from deorise.rplugin import Rplugin


if find_spec('yarp'):
    import vim
else:
    import pynvim as vim

Args = typing.List[typing.Any]

if hasattr(vim, 'plugin'):
    # Neovim only

    @vim.plugin
    class deoriseHandlers:

        def __init__(self, vim: vim.Nvim) -> None:
            self._rplugin = Rplugin(vim)

        @vim.function('_deorise_init', sync=True)  # type: ignore
        def init_channel(self, args: Args) -> None:
            self._rplugin.init_channel()

        @vim.rpc_export('_deorise_start', sync=True)  # type: ignore
        def start(self, args: Args) -> None:
            self._rplugin.start(args)

        @vim.rpc_export('_deorise_do_action', sync=True)  # type: ignore
        def do_action(self, args: Args) -> None:
            self._rplugin.do_action(args)


if find_spec('yarp'):

    global_rplugin = Rplugin(vim)

    def _deorise_init() -> None:
        pass

    def _deorise_start(args: Args) -> None:
        global_rplugin.start(args)

    def _deorise_do_action(args: Args) -> None:
        global_rplugin.do_action(args)
