#include    <stdio.h>
#include    <math.h>

/*
 * A blur kernel calculator for desktop rice.
 * May implement other kinds of blur later.
 */
double bokeh(int x, int y, double radius, int width, int height);
double gaussian(int x, int y, double radius, int width, int height);
int main()
{
    int width = 13;
    int height = 13;
    int radius = 7;
    double (*functions[])(int, int, double, int, int) = {bokeh, gaussian};
    double (*fn)(int, int, double, int, int) = NULL;
    int choice = -1;
    printf("enter function (0: bokeh, 1: gaussian blur) ");
    if (scanf("%d", &choice) == EOF || choice < 0 || choice > 1) {
        puts("invalid selection");
        return -1;
    } else {
        fn = functions[choice];
    }

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            int x = j - width / 2;
            int y = i - width / 2;
            int r = sqrt(x * x + y * y);
            if (r < radius) {
                printf("%d,", (int) fmin(fmax(round(fn(x, y, radius, width, height) * 10), 0), 9));
            } else {
                printf("0,");
            }
        }
        puts("");
    }
    puts("");
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            int x = j - width / 2;
            int y = i - width / 2;
            int r = sqrt(x * x + y * y);
            if (r < radius) {
                printf("%d,", (int) fmin(fmax(round(fn(x, y, radius, width, height) * 10), 0), 9));
            } else {
                printf("0,");
            }
        }
    }
    puts("");
}

double bokeh(int x, int y, double radius, int width, int height)
{
    double r = sqrt(x * x + y * y)*0.83;
    double lsr = log(sin(r) + 1);
    return -(lsr * lsr * lsr * lsr) * 5 + 1;
}

double gaussian(int x, int y, double radius, int width, int height)
{
    double sigma = radius;
    double mult = 1/(2*M_PI*sigma*sigma);
    double epow = pow(M_E, -(x*x + y*y) * width * 0.5 / (2*sigma*sigma));
    return mult * epow * 300;
}
