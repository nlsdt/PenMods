/* Keeps an absolute pointer device present so the compositor advertises
 * POINTER capability before a client binds the seat. Diagnostic only. */
#include <fcntl.h>
#include <linux/uinput.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>

int main(void) {
    int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd < 0) { perror("open /dev/uinput"); return 1; }
    ioctl(fd, UI_SET_EVBIT, EV_KEY);
    ioctl(fd, UI_SET_KEYBIT, BTN_LEFT);
    ioctl(fd, UI_SET_EVBIT, EV_ABS);
    ioctl(fd, UI_SET_ABSBIT, ABS_X);
    ioctl(fd, UI_SET_ABSBIT, ABS_Y);

    struct uinput_user_dev udev;
    memset(&udev, 0, sizeof(udev));
    snprintf(udev.name, UINPUT_MAX_NAME_SIZE, "penmods-pointerd");
    udev.id.bustype = BUS_USB;
    udev.id.vendor = 0x1234;
    udev.id.product = 0x5679;
    udev.id.version = 1;
    udev.absmax[ABS_X] = 169;
    udev.absmax[ABS_Y] = 319;
    if (write(fd, &udev, sizeof(udev)) != (ssize_t)sizeof(udev)) { perror("write"); return 1; }
    if (ioctl(fd, UI_DEV_CREATE) < 0) { perror("UI_DEV_CREATE"); return 1; }
    fprintf(stderr, "pointerd: device created\n");
    for (;;) sleep(3600);
}
