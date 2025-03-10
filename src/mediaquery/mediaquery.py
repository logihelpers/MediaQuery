from enum import Enum
from typing import Any, Optional, Union

from flet.core.constrained_control import ConstrainedControl
from flet.core.control import OptionalNumber, Control, OptionalControlEventCallable

class MediaQuery(ConstrainedControl):
    """
    Mediaquery Control.
    """

    def __init__(
        self,
        content: Optional[Control] = None,
        expand: Union[None, bool, int] = None,
        #
        # Control
        #
        opacity: OptionalNumber = None,
        tooltip: Optional[str] = None,
        visible: Optional[bool] = None,
        data: Any = None,
        #
        # ConstrainedControl
        #
        left: OptionalNumber = None,
        top: OptionalNumber = None,
        right: OptionalNumber = None,
        bottom: OptionalNumber = None,
        #
        # Mediaquery specific
        #
        on_size_change: OptionalControlEventCallable = None
    ):
        ConstrainedControl.__init__(
            self,
            tooltip=tooltip,
            opacity=opacity,
            visible=visible,
            data=data,
            left=left,
            top=top,
            right=right,
            bottom=bottom,
            expand=expand
        )

        self.content = content
        self.on_size_change = on_size_change

    def _get_control_name(self):
        return "mediaquery"

    # content
    @property
    def content(self) -> Optional[Control]:
        return self.__content

    @content.setter
    def content(self, value: Optional[Control]):
        self.__content = value
    
    @property
    def on_size_change(self):
        return self._get_event_handler("size_change")

    @on_size_change.setter
    def on_size_change(self, handler):
        self._add_event_handler("size_change", handler)

    def _get_children(self):
        children = []
        if self.__content:
            self.__content._set_attr_internal("n", "content")
            children.append(self.__content)
        return children
