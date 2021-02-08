using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using LaplaceFilter.Algorithm;
using LaplaceFilter.Model;
using MessageBox = System.Windows.MessageBox;

namespace LaplaceFilter
{

    public partial class MainWindow : Window
    {
        private Action<float> dispatcher;
        private List<Bitmap> transformedImages;
        private List<Thread> threads;
        private List<Bitmap> images;
        private bool CSharpImplementationMode;
        public MainWindow()
        {
            InitializeComponent();
            DataContext = new LaplaceDataContext();
            procesor.Text = Environment.ProcessorCount.ToString();

            dispatcher = (newValue) => Dispatcher.InvokeAsync(() =>
            {
                (this.DataContext as LaplaceDataContext).ProgressBar = newValue;
            });
        }

        private void Input_Path_Find(object sender, RoutedEventArgs e)
        {

            var openFile = new OpenFileDialog
            {
                Filter = "1.JPeg Image|*.jpg|2.Bitmap Image|*.bmp",
                Title = "Please select an image file."
            };
            if (openFile.ShowDialog() == System.Windows.Forms.DialogResult.OK &&
                DataContext is LaplaceDataContext context)
            {
                context.InputFilePath = openFile.FileName;
                var newBitmap = new Bitmap(openFile.FileName);
                int minSize = new[] { newBitmap.Width, newBitmap.Height }.Min();
                if (minSize >= 50)
                {
                    context.Image = newBitmap;
                    PrintImageOnGUI(context.Image);
                }
                else
                {
                    context.Image = null;
                    System.Windows.Forms.MessageBox.Show("Picture is too small. Min height/weight is 50x50.");
                }
            }
        }

        private void Filter_Button_Click(object sender, RoutedEventArgs e)
        {
            int wagtki = Int32.Parse(ileWatkow.Text);
            
            if (wagtki > 0 && wagtki < 65)
            {
                Find_Btn.IsEnabled = false;

                var context = (DataContext as LaplaceDataContext);
                context.FilteredImage = null;
                var image = context.Image;
                context.Image = null;

                this.threads = new List<Thread>();
                this.transformedImages = new List<Bitmap>();
                this.images = SplitImage(image, wagtki);
                this.CSharpImplementationMode = context.CSharpImplementationMode;

                for (int i = 0; i < wagtki; i++)
                {
                    transformedImages.Add(new Bitmap(1, 1));
                    Thread t = new Thread(performOperation)
                    {
                        Name = "" + i
                    };
                    threads.Add(t);
                }
                Stopwatch stopwatch = new Stopwatch();

                context.ElapsedTime = "Trwa filtrowanie...";
                context.ProgressBar = 0;
                ProgressBar.Visibility = Visibility.Visible;
                stopwatch.Start();

                for (int i = 0; i < wagtki; i++)
                {
                    threads[i].Start(i);
                }
                for (int i = 0; i < wagtki; i++)
                {
                    threads[i].Join();
                }

                stopwatch.Stop();
                image = MergeImage(this.transformedImages);
                context.FilteredImage = image;
                ProgressBar.Visibility = Visibility.Hidden;
                context.ElapsedTime = stopwatch.ElapsedMilliseconds.ToString();
                context.Image = image;
                PrintImageOnGUI(context.FilteredImage);
                Find_Btn.IsEnabled = true;
            }
            else
            {
                System.Windows.Forms.MessageBox.Show("Niepoprawna ilość wątków!");
            }
        }

        public void performOperation(object i_)
        {
            int i = (int)i_;
            
            Bitmap transformedImage;
            try
            {
                if (this.CSharpImplementationMode)
                {
                    transformedImage = RunCSharpLaplaceFilter(this.images[i]);
                }
                else
                {
                    transformedImage = RunAssemblyImplementationFilter(this.images[i]);
                }
                this.transformedImages[i] = transformedImage;
            }
            catch (AccessViolationException error)
            {
                MessageBox.Show("Wątek nr " + Thread.CurrentThread.Name + ": " + error.Message, error.GetType().ToString());
            }
            catch (Exception XD)
            {
                MessageBox.Show("Wątek nr " + Thread.CurrentThread.Name + ": " + XD.Message, XD.GetType().ToString());
            }
        }

        public static List<Bitmap> SplitImage(Bitmap image, int n)
        {
            int width = image.Width / n;
            List<Bitmap> result = new List<Bitmap>();
            for (int i = 0; i < n; i++)
            {
                int widthOfThisPart = width;
                if (i == n - 1)
                {
                    int extraWidth = image.Width - (width * n);
                    widthOfThisPart += extraWidth;
                }

                int orgWidthOfThisPart = widthOfThisPart;

                //add columns from adjacent parts (just for good result at the ends of part)
                //int leftAdd = parameters.CentrPntX;
                //int rightAdd = parameters.ElemWidth - parameters.CentrPntX - 1;
                int add = 1;
                if (i == 0)
                {
                    widthOfThisPart += add;
                }
                else if (i == n - 1)
                {
                    widthOfThisPart += add;
                }
                else
                {
                    widthOfThisPart += add;
                    widthOfThisPart += add;
                }
                //zabezpieczenie przed przekroczeniem zakresu z prawej strony
                if (Math.Max(i * width - add, 0) + widthOfThisPart > image.Width)
                {
                    widthOfThisPart = image.Width - Math.Max(i * width - add, 0);
                }
                //Rectangle cropArea = new Rectangle(0 + i * width, 0, widthOfThisPart, image.Height);
                Rectangle cropArea;
                if (i == 0)
                    cropArea = new Rectangle(0, 0, widthOfThisPart, image.Height);
                else
                    cropArea = new Rectangle(Math.Max(i * width - add, 0), 0, widthOfThisPart, image.Height);

                Bitmap bmpCrop = image.Clone(cropArea, image.PixelFormat);

                result.Add(bmpCrop);
            }
            return result;
        }

        public static Bitmap MergeImage(List<Bitmap> images)
        {
            int width = 0;
            int k = 0;
            foreach(var image in images)
            {
                if (k == 0 && k == images.Count - 1)
                    width += image.Width - 1;
                else
                    width += image.Width - 2;
                k++;
            }
            
            Bitmap result = new Bitmap(width, images[0].Height);
            using (Graphics g = Graphics.FromImage(result))
            {
                int i = 0;
                foreach(var image in images)
                {
                    width = 0;
                    for (int j = 0; j < i; j++)
                    {
                        if (j == 0 && j == images.Count - 1) 
                            width += images[j].Width - 1;
                        else
                            width += images[j].Width - 2;
                    }
                    Rectangle cropArea;
                    if (i == 0)
                        cropArea = new Rectangle(0, 0, image.Width - 1, image.Height);
                    else if (i < images.Count - 1)
                        cropArea = new Rectangle(1, 0, image.Width - 2, image.Height);
                    else
                        cropArea = new Rectangle(1, 0, image.Width - 1, image.Height);

                    Bitmap bmpCrop = image.Clone(cropArea, image.PixelFormat);

                    g.DrawImage(bmpCrop, new System.Drawing.Point(0 + width, 0));
                    i++;
                }

            }
            return result;
        }

        private void Save_Button_Click(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveFileDialog = new SaveFileDialog
            {
                Filter = "1.JPeg Image|*.jpg|2.Bitmap Image|*.bmp",
                Title = "Save an Image File"
            };
            var result = saveFileDialog.ShowDialog();
            if (result == System.Windows.Forms.DialogResult.OK)
            {
                var context = (DataContext as LaplaceDataContext);
                switch (saveFileDialog.FilterIndex)
                {
                    case 1:
                        context.FilteredImage.Save(saveFileDialog.FileName, ImageFormat.Jpeg);
                        break;
                    case 2:
                        context.FilteredImage.Save(saveFileDialog.FileName, ImageFormat.Bmp);
                        break;
                    default:
                        break;
                }
            }
        }

        private Bitmap RunAssemblyImplementationFilter(Bitmap image)
        {
             return new LaplaceFilterAssembly(image).ApplyAssemblyFilter(image);
        }

        private int[] _laplaceMask1 = new int[] {
                        0, -1, 0,
                        -1, 4, -1,
                        0, -1, 0 };

        private int[] _laplaceMask2 = new int[] {
                        -1, -1, -1,
                        -1,  8, -1,
                        -1, -1, -1 };

        private int[] _laplaceMask3 = new int[] {
                        1, -2, 1,
                        -2,  4, -2,
                        1, -2, 1 };

        private Bitmap RunCSharpLaplaceFilter(Bitmap image)
        {
                var laplaceFilter = new LaplaceFilterCSharp(_laplaceMask2, image, dispatcher);
                laplaceFilter.ApplyUnsafe();

                return laplaceFilter.FilteredImage;
        }

        private void PrintImageOnGUI(Bitmap image)
        {
            using (MemoryStream memory = new MemoryStream())
            {
                image.Save(memory, System.Drawing.Imaging.ImageFormat.Bmp);
                memory.Position = 0;
                BitmapImage bitmapimage = new BitmapImage();
                bitmapimage.BeginInit();
                bitmapimage.StreamSource = memory;
                bitmapimage.CacheOption = BitmapCacheOption.OnLoad;
                bitmapimage.EndInit();
                bitmapimage.Freeze();
                Dispatcher.BeginInvoke(new Action(() =>
                {
                    (DataContext as LaplaceDataContext).ImageSource = bitmapimage;
                }));
            }
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            var context = (DataContext as LaplaceDataContext);
            try
            {
                new Histogram(context.Image).Show();
            }
            catch (Exception XD)
            {
                MessageBox.Show(XD.Message, XD.GetType().ToString());
            }
        }
    }
}